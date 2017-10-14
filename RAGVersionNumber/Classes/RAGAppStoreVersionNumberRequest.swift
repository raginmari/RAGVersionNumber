//
//  RAGAppStoreVersionNumberRequest.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

class RAGAppStoreVersionNumberRequest {
    
    let parser: RAGAppStoreLookupResultParsing
    
    init(parser: RAGAppStoreLookupResultParsing) {
        self.parser = parser
    }
    
    enum Result {
        case versionNumber(VersionNumber)
        case error(Error?)
    }
    
    func fetchWithAppStoreCountryCode(_ countryCode: String, completion: (Result) -> Void) {
        // http://itunes.apple.com/lookup?bundleId=de.agravis.iqfeed&country=de
    }
}
