//
//  AppStoreLookupResultParser.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

typealias JSONObject = [String: Any]

enum AppStoreLookupError: Error {
    
    /// The lookup result has no results or an empty array of results
    case notFound
    
    /// The lookup result has more than one result
    case notUnique
    
    /// The lookup result JSON format is unsupported
    case unsupportedFormat
}

public protocol AppStoreLookupResultParsing {
    
    func parseVersionString(fromJSON: [String: Any]) throws -> String
}

class AppStoreLookupResultParser: AppStoreLookupResultParsing {
    
    private enum JSONKeys {
        
        static let resultCount = "resultCount"
        static let results = "results"
        static let version = "version"
    }
    
    func parseVersionString(fromJSON jsonObject: [String: Any]) throws -> String {
        guard !jsonObject.isEmpty else {
            throw AppStoreLookupError.unsupportedFormat
        }
        
        guard let numberOfResults = jsonObject[JSONKeys.resultCount] as? NSNumber else {
            throw AppStoreLookupError.unsupportedFormat
        }
        
        guard let resultsArray = jsonObject[JSONKeys.results] as? Array<JSONObject> else {
            throw AppStoreLookupError.unsupportedFormat
        }
        
        guard numberOfResults.intValue > 0 else {
            throw AppStoreLookupError.notFound
        }
        
        guard numberOfResults.intValue < 2 else {
            throw AppStoreLookupError.notUnique
        }
        
        let result = resultsArray[0];
        guard let versionString = result[JSONKeys.version] as? String else {
            throw AppStoreLookupError.unsupportedFormat
        }
        
        return versionString
    }
}
