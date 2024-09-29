//
//  AddSummaryViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/21.
//

import Foundation
import CoreData
import XLog
import Combine

class AddSummaryViewModel: ObservableObject {
    let item: SummaryItem
    let moc: NSManagedObjectContext
    
    @Published var defaultTitle = ""
    @Published var dayId = 0
    
    @Published var selectedPrompt: PromptEntity? {
        didSet {
            if let prompt = selectedPrompt {
                temperature = prompt.temperature
            }
        }
    }
    
    @Published var temperature = 0.5
    @Published var promptToEdit: PromptEntity?
    @Published var showAddPrompt: Bool = false
    
    @Published var fatalErrorMessage = "" {
        didSet {
            showFatalError = true
        }
    }
    @Published var showFatalError = false
    @Published var memoContent = ""
    @Published var summaryMessage = ""
    @Published var summaryMessageCharCount = 0
    
    @Published var navPath: [AddSummaryNavPath] = []
    
    @Published var isSummarizing = false
    @Published var summarizedResponse = ""
    @Published var summaryError = ""
    @Published var saved = false
    @Published var model: OpenAIChatModel = .gpt_4o_mini
    
    @Published var validMemos = [MemoEntity]()
    @Published var excludedMemos = Set<MemoEntity>()
    @Published var selectedMemos = [MemoEntity]()
    
    private var cancellationTask: Task<Void, Never>? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(item: SummaryItem, moc: NSManagedObjectContext) {
        self.item = item
        self.moc = moc
        
        if case let .day(id) = item {
            dayId = id
        }
        
        self.defaultTitle = L(.sum_title_default, DateHelper.formatIdentifier(dayId, dateFormat: "yyyy-MM-dd"))
        
        $summaryMessage.map {
            $0.count
        }.assign(to: &$summaryMessageCharCount)
    }
    
    deinit {
        #if DEBUG
            XLog.debug("✖︎ AddSummaryViewModel", source: "Summary")
        #endif
    }
    
    func fetchEntries() {
        let fetchRequest = MemoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day = %d", dayId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MemoEntity.createdAt, ascending: true)]
        var ret = ""
        do {
            let memos = try moc.fetch(fetchRequest).filter { !$0.viewContent.isEmpty }
            validMemos = memos
            for memo in memos {
                ret.append("\n[\(memo.viewTime)] \(memo.viewContent)\n")
            }
            
            if ret.count < Constants.Summary.lengthLimit {
                fatalErrorMessage = L(.sum_text_too_short)
            } else {
                memoContent = ret
            }
        } catch {
            XLog.error(error, source: "Sumary")
        }
        
        $excludedMemos.sink { [unowned self] s in
            selectedMemos = validMemos.filter { !s.contains($0) }
        }.store(in: &cancellables)
    }
    
    func generateMessage() {
        guard let prompt = selectedPrompt else { return }
        
        var content = ""
        for memo in selectedMemos {
            content.append("\n[\(memo.viewTime)] \(memo.viewContent)\n")
        }
        
        if content.count < Constants.Summary.lengthLimit {
            fatalErrorMessage = L(.sum_text_too_short)
        }
        
        var ret = replacePlaceHolders(prompt.viewContent)
        ret.append("\n\n------")
        ret.append(content)
        ret.append("------\n")
        summaryMessage = ret
    }
    
    func replacePlaceHolders(_ message: String) -> String {
        var ret = message
        let items = [
            "date": DateHelper.formatIdentifier(dayId),
        ]
        for (key, value) in items {
            ret = ret.replacingOccurrences(of: "{{\(key)}}", with: "\(value)")
        }
        return ret
    }
    
    func summarize() {
        if isSummarizing { return }
        
        var server = "default"
        if Config.shared.serverType == .custom {
            
            if !Config.shared.isServerValid {
                summaryError = L(.error_invalid_custom_server)
                return
            }
            
            server = Config.shared.serverHost
            model = Config.shared.aiModel
        }
        
        XLog.info("Summarize (prompt: \(selectedPrompt?.viewTitle ?? ""), server: \(server), temp: \(temperature), model: \(model.name))", source: "Summary")
        
        cancellationTask = Task { @MainActor in
            isSummarizing = true
            do {
                summaryError = ""
                summarizedResponse = ""
                let stream = try await OpenAIClient().summarize(summaryMessage, model: model, temperature: temperature)
                for try await text in stream {
                    // first response
                    if summarizedResponse == "" {
                        XLog.info("Sent characters = \(summaryMessageCharCount)", source: "Summary")
                        DataContainer.shared.recordUsage(charsSent: summaryMessageCharCount)
                    }
                    summarizedResponse += text
                }
            } catch {
                summaryError = ErrorHelper.desc(error)
                XLog.error(error, source: "Summary")
            }
            isSummarizing = false
        }
    }
    
    func save() {
        let summary = SummaryEntity.newEntity(moc: moc)
        summary.content = summarizedResponse
        summary.title = defaultTitle
        
        do {
            try moc.save()
            saved = true
        } catch {
            XLog.error(error, source: "Summary")
        }
    }
    
    func cancelTasks() {
        cancellationTask?.cancel()
    }
}
