//
//  RAGAppStoreVersionNumberLookupTests.swift
//  RAGVersionNumber
//
//  Created by Reimar Twelker on 16.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import RAGVersionNumber

class RAGAppStoreVersionNumberLookupTests: XCTestCase {
    
    private var sut: RAGAppStoreVersionNumberLookup!
    private var parser: MockParser!
    private var session: MockSession!
    
    override func setUp() {
        super.setUp()
     
        parser = MockParser()
        session = MockSession()
        sut = RAGAppStoreVersionNumberLookup(parser: parser, session: session)
    }
    
    override func tearDown() {
        sut = nil
        session = nil
        parser = nil
        
        super.tearDown()
    }
    
    func test_PerformLookupRequestsExpectedURL() {
        _ = sut.performLookup(withBundleIdentifier: "com.example.test", appStoreCountryCode: "de") { _ in }
        
        let expectedURL = URL.appStoreLookupURL(bundleIdentifier: "com.example.test", appStoreCountryCode: "de")
        XCTAssertEqual(session.dataTaskRequest?.url!, expectedURL)
    }
    
    func test_PerformLookupStartsDataTask() {
        _ = sut.performLookup(withBundleIdentifier: "com.example.test", appStoreCountryCode: "de") { _ in }
        
        XCTAssertTrue(session.dataTask.resumeWasCalled)
    }
}

private class MockParser: RAGAppStoreLookupResultParsing {
    
    var parseVersionStringError: Error? = nil
    var parseVersionStringResult = ""
    
    func parseVersionString(fromJSON: [String : Any]) throws -> String {
        if parseVersionStringError != nil { throw parseVersionStringError! }
        return parseVersionStringResult
    }
}

private class MockSession: RAGURLSessionProtocol {
    
    var dataTaskRequest: URLRequest? = nil
    var dataTaskResultData: Data? = nil
    var dataTaskResultURLResponse: URLResponse? = nil
    var dataTaskResultError: Error? = nil
    var dataTask = MockDataTask()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RAGURLSessionDataTaskProtocol {
        dataTaskRequest = request
        
        // Defer completion of the request
        DispatchQueue.main.async {
            completionHandler(self.dataTaskResultData,
                              self.dataTaskResultURLResponse,
                              self.dataTaskResultError)
        }
        
        return dataTask
    }
}

private class MockDataTask: RAGURLSessionDataTaskProtocol {
    
    var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
