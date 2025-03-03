//
//  Constants.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation

struct Constants {
    
    static let api_base_url = URL(string: "https://api.alog.tarbotech.com/")!
    static let user_agent = "ALog \(AppInfo.appVersion)"
    
    struct Contact {
        static let twitter = "https://twitter.com/tarbo_du"
        static let github = "https://github.com/duxins"
        static let email = "support@tarbotech.com"
    }
    
    struct Legal {
        static let repo_url = "https://github.com/duxins/alog"
        static let privacy_policy_url = "https://alog.tarbotech.com/privacy_policy.html"
        static let terms_url = "https://alog.tarbotech.com/terms.html"
    }
    
    struct OpenAI {
        static let api_key_url = "https://platform.openai.com/account/api-keys"
        static let api_host = "https://api.openai.com/"
    }
    
    struct Summary {
        static let lengthLimit = 10
    }
    
    struct IAP {
        static let premiumProductId = "app.tarbo.memo.premium"
    }
    
    struct Limit {
        static let prompts = 3
        static let daily_characters = 20000
        static let daily_characters_premium = daily_characters * 5
    }
    
}
