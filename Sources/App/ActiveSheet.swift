//
//  ActiveSheet.swift
//  VoiceLog
//
//  Created by Xin Du on 2023/07/22.
//

import Foundation

enum ActiveSheet: Identifiable, Equatable {
    case settings
    case quickMemo
    /// Generate summary
    case summarize(SummaryItem)
    case micPermission
    case editMemo(MemoEntity)
    case editSummary(SummaryEntity)
    
    var id: String {
        switch self {
        case .settings: return "settings"
        case .quickMemo: return "quick"
        case .summarize(let item): return item.id
        case .micPermission: return "mic"
        case .editMemo(let item): return "edit_memo_\(item.id ?? "")"
        case .editSummary(let item): return "edit_summary_\(item.id ?? "")"
        }
    }
    
    static func == (lhs: ActiveSheet, rhs: ActiveSheet) -> Bool {
        return lhs.id == rhs.id
    }
}
