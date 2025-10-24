//
//  OpenAIChatModel.swift
//  VoiceLog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation

enum OpenAIChatModel: String, CaseIterable {
    case gpt_4
    case gpt_4o_mini
    case gpt_4o

    var displayName: String {
        switch self {
        case .gpt_4: return "GPT-4"
        case .gpt_4o: return "GPT-4o"
        case .gpt_4o_mini: return "GPT-4o mini"
        }
    }

    var name: String {
        switch self {
        case .gpt_4: return "gpt-4"
        case .gpt_4o: return "gpt-4o"
        case .gpt_4o_mini: return "gpt-4o-mini"
        }
    }
}
