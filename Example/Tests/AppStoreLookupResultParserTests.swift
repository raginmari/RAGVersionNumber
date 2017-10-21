//
//  AppStoreLookupResultParserTests.swift
//  RAGVersionNumber
//
//  Created by Reimar Twelker on 14.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import RAGVersionNumber

class AppStoreLookupResultParserTests: XCTestCase {
    
    private enum JSONStrings {
        static let empty = "{}"
        static let missingResultCount = "{\"results\":[]}"
        static let missingResults = "{\"resultCount\":0}"
        static let noResults = "{\"resultCount\":0,\"results\":[]}"
        static let tooManyResults = "{\"resultCount\":2,\"results\":[{\"version\":\"1.2.3\"},{\"version\":\"2.0.0\"}]}"
    }
    
    func test_parseEmptyJSONThrowsUnsupportedFormatError() {
        let sut = AppStoreLookupResultParser()
        let json = makeJSONObject(string: JSONStrings.empty)
        
        XCTAssertThrowsError(try sut.parseVersionString(fromJSON: json)) { (error) in
            XCTAssertEqual(error as? AppStoreLookupError, AppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONMissingResultCountAttributeThrowsUnsupportedFormatError() {
        let sut = AppStoreLookupResultParser()
        let json = makeJSONObject(string: JSONStrings.missingResultCount)
        
        XCTAssertThrowsError(try sut.parseVersionString(fromJSON: json)) { (error) in
            XCTAssertEqual(error as? AppStoreLookupError, AppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONMissingResultsAttributeThrowsUnsupportedFormatError() {
        let sut = AppStoreLookupResultParser()
        let json = makeJSONObject(string: JSONStrings.missingResults)
        
        XCTAssertThrowsError(try sut.parseVersionString(fromJSON: json)) { (error) in
            XCTAssertEqual(error as? AppStoreLookupError, AppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONWithNoResultsThrowsNotFoundError() {
        let sut = AppStoreLookupResultParser()
        let json = makeJSONObject(string: JSONStrings.noResults)
        
        XCTAssertThrowsError(try sut.parseVersionString(fromJSON: json)) { (error) in
            XCTAssertEqual(error as? AppStoreLookupError, AppStoreLookupError.notFound)
        }
    }
    
    func test_parseJSONWithMoreThanOneResultThrowsNotUniqueError() {
        let sut = AppStoreLookupResultParser()
        let json = makeJSONObject(string: JSONStrings.tooManyResults)
        
        XCTAssertThrowsError(try sut.parseVersionString(fromJSON: json)) { (error) in
            XCTAssertEqual(error as? AppStoreLookupError, AppStoreLookupError.notUnique)
        }
    }
    
    func test_ParseValidJSON() {
        let jsonFormat = "{\"resultCount\":1,\"results\":[{\"version\":\"%@\"}]}"
        
        let versionStrings = [
            "1.0.0",
            "1.1.0",
            "1.1.4"
        ]
        
        let sut = AppStoreLookupResultParser()
        
        for expectedVersionString in versionStrings {
            let jsonString = String(format: jsonFormat, expectedVersionString)
            let json = makeJSONObject(string: jsonString)
            
            let versionString = try? sut.parseVersionString(fromJSON: json)
            XCTAssertEqual(versionString, expectedVersionString)
        }
    }
    
    private func makeJSONObject(string: String) -> JSONObject {
        let data = string.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONObject
        
        return json
    }
}
