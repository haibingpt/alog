//
//  AppInfo.swift
//  VoiceLog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation

struct AppInfo {
    static let appStoreURL: URL = {
        let urlString = Bundle.main.infoDictionary?["AppStoreURL"] as! String
        return URL(string: urlString)!
    }()
    
    static let reviewURL: URL = {
        return appStoreURL.appending(queryItems: [.init(name: "action", value: "write-review")])
    }()
    
    static let appVersion: String = {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()
    
    static let buildVersion: String = {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }()
    
    public static let gitHash: String = {
        guard let hash = Bundle.main.infoDictionary?["GIT_HASH"] as? String, hash != "" else {
            return ""
        }
        return hash
    }()
    
    static let sourceURL: URL = {
        let baseURL = URL(string: Constants.Legal.repo_url)!
        guard !gitHash.isEmpty else { return baseURL }
        
        return baseURL.appendingPathComponent("tree").appendingPathComponent(gitHash)
    }()
    
}
