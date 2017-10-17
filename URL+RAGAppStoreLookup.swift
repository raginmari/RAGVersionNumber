//
//  URL+RAGAppStoreLookup.swift
//  Pods
//
//  Created by Reimar Twelker on 15.10.17.
//
//

import Foundation

extension URL {
    
    static func appStoreLookupURL(bundleIdentifier: String, appStoreCountryCode countryCode: String = "us") -> URL? {
        let urlFormat = "https://itunes.apple.com/lookup?bundleId=%@&country=%@"
        let urlString = String(format: urlFormat, bundleIdentifier, countryCode)
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
}
