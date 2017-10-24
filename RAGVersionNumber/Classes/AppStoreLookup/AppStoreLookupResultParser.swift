//
//  AppStoreLookupResultParser.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

typealias JSONObject = [String: Any]

public protocol AppStoreLookupResultParsing {
    
    
    /// Parses a version string from the given iTunes lookup JSON object.
    ///
    /// - Parameter fromJSON: a JSON dictionary received from an iTunes lookup request
    /// - Returns: the version string in the given JSON
    /// - Throws: AppStoreLookupResultParserError if the JSON is of an unsupported format or the version string cannot be found
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
            throw AppStoreLookupResultParserError.unsupportedFormat
        }
        
        guard let numberOfResults = jsonObject[JSONKeys.resultCount] as? NSNumber else {
            throw AppStoreLookupResultParserError.unsupportedFormat
        }
        
        guard let resultsArray = jsonObject[JSONKeys.results] as? Array<JSONObject> else {
            throw AppStoreLookupResultParserError.unsupportedFormat
        }
        
        guard numberOfResults.intValue > 0 else {
            throw AppStoreLookupResultParserError.notFound
        }
        
        guard numberOfResults.intValue < 2 else {
            throw AppStoreLookupResultParserError.notUnique
        }
        
        let result = resultsArray[0];
        guard let versionString = result[JSONKeys.version] as? String else {
            throw AppStoreLookupResultParserError.unsupportedFormat
        }
        
        return versionString
    }
}
