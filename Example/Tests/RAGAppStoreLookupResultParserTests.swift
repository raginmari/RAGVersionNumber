//
//  RAGAppStoreLookupResultParserTests.swift
//  RAGVersionNumber
//
//  Created by Reimar Twelker on 14.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import RAGVersionNumber

class RAGAppStoreLookupResultParserTests: XCTestCase {
    
    private enum JSONStrings {
        static let empty = "{}"
        static let missingResultCount = "{\"results\":[]}"
        static let missingResults = "{\"resultCount\":0}"
        static let noResults = "{\"resultCount\":0,\"results\":[]}"
        static let tooManyResults = "{\"resultCount\":2,\"results\":[{\"version\":\"1.2.3\"},{\"version\":\"2.0.0\"}]}"
    }
    
    func test_parseEmptyJSONThrowsUnsupportedFormatError() {
        let json = makeJSONObject(string: JSONStrings.empty)
        let sut = RAGAppStoreLookupResultParser(jsonObject: json)
        
        XCTAssertThrowsError(try sut.parseVersionString()) { (error) in
            XCTAssertEqual(error as? RAGAppStoreLookupError, RAGAppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONMissingResultCountAttributeThrowsUnsupportedFormatError() {
        let json = makeJSONObject(string: JSONStrings.missingResultCount)
        let sut = RAGAppStoreLookupResultParser(jsonObject: json)
        
        XCTAssertThrowsError(try sut.parseVersionString()) { (error) in
            XCTAssertEqual(error as? RAGAppStoreLookupError, RAGAppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONMissingResultsAttributeThrowsUnsupportedFormatError() {
        let json = makeJSONObject(string: JSONStrings.missingResults)
        let sut = RAGAppStoreLookupResultParser(jsonObject: json)
        
        XCTAssertThrowsError(try sut.parseVersionString()) { (error) in
            XCTAssertEqual(error as? RAGAppStoreLookupError, RAGAppStoreLookupError.unsupportedFormat)
        }
    }
    
    func test_parseJSONWithNoResultsThrowsNotFoundError() {
        let json = makeJSONObject(string: JSONStrings.noResults)
        let sut = RAGAppStoreLookupResultParser(jsonObject: json)
        
        XCTAssertThrowsError(try sut.parseVersionString()) { (error) in
            XCTAssertEqual(error as? RAGAppStoreLookupError, RAGAppStoreLookupError.notFound)
        }
    }
    
    func test_parseJSONWithMoreThanOneResultThrowsNotUniqueError() {
        let json = makeJSONObject(string: JSONStrings.tooManyResults)
        let sut = RAGAppStoreLookupResultParser(jsonObject: json)
        
        XCTAssertThrowsError(try sut.parseVersionString()) { (error) in
            XCTAssertEqual(error as? RAGAppStoreLookupError, RAGAppStoreLookupError.notUnique)
        }
    }
    
    func test_ParseValidJSON() {
        let jsonFormat = "{\"resultCount\":1,\"results\":[{\"version\":\"%@\"}]}"
        
        let versionStrings = [
            "1.0.0",
            "1.1.0",
            "1.1.4"
        ]
        
        for expectedVersionString in versionStrings {
            let jsonString = String(format: jsonFormat, expectedVersionString)
            let json = makeJSONObject(string: jsonString)
            let sut = RAGAppStoreLookupResultParser(jsonObject: json)
            
            let versionString = try? sut.parseVersionString()
            XCTAssertEqual(versionString, expectedVersionString)
        }
    }
    
    private func makeJSONObject(string: String) -> RAGJSONObject {
        let data = string.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! RAGJSONObject
        
        return json
    }
}
