//
//  AppStoreVersionNumberLookupTests.swift
//  RAGVersionNumber
//
//  Created by Reimar Twelker on 16.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import RAGVersionNumber

class AppStoreVersionNumberLookupTests: XCTestCase {
    
    private enum TestError: Error {
        
        case any
    }
    
    private var sut: AppStoreVersionNumberLookup!
    private var parser: MockParser!
    private var session: MockSession!
    
    override func setUp() {
        super.setUp()
     
        parser = MockParser()
        session = MockSession()
        sut = AppStoreVersionNumberLookup(parser: parser, session: session)
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
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { _ in }
        
        XCTAssertTrue(session.dataTask.resumeWasCalled)
    }
    
    func test_PerformLookupReturnsErrorIfResponseContainsError() {
        session.dataTaskResultError = TestError.any
        session.dataTaskResultResponse = nil
        session.dataTaskResultData = nil
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseLacksResponseOrData() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = nil
        session.dataTaskResultData = nil
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseStatusIsNot200() {
        let statusCodes = [
            301, 302,
            401, 404,
            500, 503
        ]
        var expectations = [XCTestExpectation]()
        
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        statusCodes.forEach {
            let url = URL(string: "com.example.test")!
            let response = HTTPURLResponse(url: url, statusCode: $0, httpVersion: nil, headerFields: nil)
            session.dataTaskResultResponse = response
            
            let expectsError = expectation(description: "Returns error")
            expectations.append(expectsError)
            
            _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
                if case .failure = result { expectsError.fulfill() }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupMaps401ToCustomError() {
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        session.dataTaskResultResponse = response
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case let .failure(error) = result {
                if (error as? AppStoreVersionNumberLookupError) == .http4xx(401) {
                    expectsError.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupMaps404ToCustomError() {
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        session.dataTaskResultResponse = response
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case let .failure(error) = result {
                if (error as? AppStoreVersionNumberLookupError) == .http4xx(404) {
                    expectsError.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupMaps500ToCustomError() {
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.dataTaskResultResponse = response
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case let .failure(error) = result {
                if (error as? AppStoreVersionNumberLookupError) == .http5xx(500) {
                    expectsError.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseDataIsInvalid() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = makeResponseWithStatus200()
        session.dataTaskResultData = makeInvalidResponseData()
        
        let expectsError = expectation(description: "Returns error")
        
        _ = sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    private func makeResponseWithStatus200() -> URLResponse {
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        return response
    }
    
    private func makeInvalidResponseData() -> Data {
        let data = "...".data(using: .utf8)!
        
        return data
    }
    
    private func makeArbitraryResponseData() -> Data {
        let data = "test".data(using: .utf8)!
        
        return data
    }
}

private class MockParser: AppStoreLookupResultParsing {
    
    var parseVersionStringError: Error? = nil
    var parseVersionStringResult = ""
    
    func parseVersionString(fromJSON: [String : Any]) throws -> String {
        if parseVersionStringError != nil { throw parseVersionStringError! }
        return parseVersionStringResult
    }
}

private class MockSession: URLSessionProtocol {
    
    var dataTaskRequest: URLRequest? = nil
    var dataTaskResultData: Data? = nil
    var dataTaskResultResponse: URLResponse? = nil
    var dataTaskResultError: Error? = nil
    var dataTask = MockDataTask()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        dataTaskRequest = request
        
        // Defer completion of the request
        DispatchQueue.main.async {
            completionHandler(self.dataTaskResultData,
                              self.dataTaskResultResponse,
                              self.dataTaskResultError)
        }
        
        return dataTask
    }
}

private class MockDataTask: URLSessionDataTaskProtocol {
    
    var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
