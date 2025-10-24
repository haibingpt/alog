//
//  AppDelegate+SnapshotTesting.swift
//  VoiceLog
//
//  Created by Xin Du on 2023/07/23.
//

import Foundation
import XLang

#if SNAPSHOT
extension AppDelegate {
    func setupSnapshotTestEnvironment() {
        let moc = DataContainer.shared.context
        let config = Config.shared
        
        AppState.shared.isPremium = true
        
        // MARK: - RESET SETTINGS
        config.serverType = .custom
        config.serverHost = "http://127.0.0.1:8888/"
        config.aiModel = .gpt_4
        config.sumEnabled = true
        config.transEnabled = true
        config.transLang = .en
        config.transProvider = .openai
        
        // MARK: - RESET MEMOS
        let request = MemoEntity.fetchRequest()
        let results = try! moc.fetch(request)
        for result in results {
            moc.delete(result)
        }
        
        // MARK: - Fake Data
        let items: [[String]]
        
        if Bundle.main.preferredLocalizations.first! == "zh-Hans" {
            config.transLang = .zh_hans
            items = [
                ["06:03", "起床，希望今天会有好运。"],
                ["08:30", "上班，乘坐地铁，人来人往。"],
                ["09:30", "开始工作，处理邮件，安排会议。"],
                ["12:08", "午餐，公司食堂的鱼香肉丝，赞！"],
                ["13:30", "继续工作，为下周的演讲做准备。"],
                ["18:05", "下班逛超市，准备晚餐。"],
                ["21:00", "瑜伽，舒缓压力。"],
                ["23:00", "睡觉，期待明天的到来，晚安"]
            ]
        } else {
            items = [
                ["06:03", "Woke up, kind of a bummer."],
                ["07:08", "Had a big bowl of cereal, too many marshmallows maybe."],
                ["07:22", "Morning jog for 2 miles. My lungs, they're screaming!"],
                ["08:00", "Rushed shower. Thought I saw a spider. It was just shampoo."],
                ["08:32", "Hopped on the school bus. Sally's hairstyle, no comments."],
                ["12:21", "Lunch. Pizza for the third time this week. No regrets."],
                ["15:58", "Soccer practice. Sweating buckets, feeling awesome."],
                ["19:10", "Dinner. Mom's meatloaf, always a hit."],
                ["22:23", "Lights out. Big day tomorrow, looking forward to it."]
            ]
        }
        
        for item in items {
            let m = MemoEntity(context: moc)
            m.id = UUID().uuidString
            m.content = item[1]
            m.file = "fake_path"
            m.day = Int32(DateHelper.identifier(from: Date()))
            m.timezone = "Asia/Tokyo"
            let time = item[0].split(separator: ":").map { Int($0)! }
            m.createdAt = DateHelper.timeToDate(h: time[0], m: time[1])
        }
        
        // MARK: - RESET PROMPTS
        let prompts = try! moc.fetch(PromptEntity.fetchRequest())
        for prompt in prompts {
            moc.delete(prompt)
        }
        
        let prompt = PromptEntity(context: moc)
        prompt.title = L(._default)
        prompt.temperature = 0.5
        prompt.content = L(.prompt_content_template)
        prompt.createdAt = Date()
        try! moc.save()
    }
}
#endif
