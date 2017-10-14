//
//  RAGAppStoreLookupResultParser.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

typealias RAGJSONObject = [String: Any]

enum RAGAppStoreLookupError: Error {
    
    /// The lookup result has no results or an empty array of results
    case notFound
    
    /// The lookup result has more than one result
    case notUnique
    
    /// The lookup result JSON format is unsupported
    case unsupportedFormat
}

protocol RAGAppStoreLookupResultParsing {
    
    init(jsonObject: RAGJSONObject)
    
    func parseVersionString() throws -> String
}

class RAGAppStoreLookupResultParser: RAGAppStoreLookupResultParsing {
    
    private enum JSONKeys {
        
        static let resultCount = "resultCount"
        static let results = "results"
        static let version = "version"
    }
    
    let jsonObject: RAGJSONObject
    
    required init(jsonObject: RAGJSONObject) {
        self.jsonObject = jsonObject
    }
    
    func parseVersionString() throws -> String {
        guard !jsonObject.isEmpty else {
            throw RAGAppStoreLookupError.unsupportedFormat
        }
        
        guard let numberOfResults = jsonObject[JSONKeys.resultCount] as? NSNumber else {
            throw RAGAppStoreLookupError.unsupportedFormat
        }
        
        guard let resultsArray = jsonObject[JSONKeys.results] as? Array<RAGJSONObject> else {
            throw RAGAppStoreLookupError.unsupportedFormat
        }
        
        guard numberOfResults.intValue > 0 else {
            throw RAGAppStoreLookupError.notFound
        }
        
        guard numberOfResults.intValue < 2 else {
            throw RAGAppStoreLookupError.notUnique
        }
        
        let result = resultsArray[0];
        guard let versionString = result[JSONKeys.version] as? String else {
            throw RAGAppStoreLookupError.unsupportedFormat
        }
        
        return versionString
    }
}
