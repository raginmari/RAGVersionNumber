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
    
    private var liveLookup: AppStoreVersionNumberLookup!
    
    override func setUp() {
        super.setUp()
     
        sut = AppStoreVersionNumberLookup()
     
        session = MockSession()
        sut.session = session
        
        parser = MockParser()
        sut.parser = parser
    }
    
    override func tearDown() {
        sut = nil
        parser = nil
        session = nil
        liveLookup = nil
        
        super.tearDown()
    }
    
    func test_DefaultSessionIsOfExpectedType() {
        let sut = AppStoreVersionNumberLookup()
        
        let session = sut.session
        XCTAssertTrue(session is URLSession)
    }
    
    func test_DefaultParserIsOfExpectedType() {
        let sut = AppStoreVersionNumberLookup()
        
        let parser = sut.parser
        XCTAssertTrue(parser is AppStoreLookupResultParser)
    }
    
    func test_PerformLookupRequestsExpectedURL() {
        sut.performLookup(withBundleIdentifier: "com.example.test", appStoreCountryCode: "de") { _ in }
        
        let expectedURL = URL.appStoreLookupURL(bundleIdentifier: "com.example.test", appStoreCountryCode: "de")
        XCTAssertEqual(session.dataTaskRequest?.url!, expectedURL)
    }
    
    func test_PerformLookupStartsDataTask() {
        sut.performLookup(withBundleIdentifier: "com.example.test") { _ in }
        
        XCTAssertTrue(session.dataTask.resumeWasCalled)
    }
    
    func test_PerformLookupReturnsErrorIfBundleIdentifierIsInvalid() {
        let expectsError = expectation(description: "Returns error")
        
        // Note: the bundle identifier is passed as a parameter in the GET query to the iTunes lookup API
        
        sut.performLookup(withBundleIdentifier: "\n", appStoreCountryCode: "de") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseContainsError() {
        session.dataTaskResultError = TestError.any
        session.dataTaskResultResponse = nil
        session.dataTaskResultData = nil
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseLacksResponseOrData() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = nil
        session.dataTaskResultData = nil
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupMaps301ToError() {
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 301, httpVersion: nil, headerFields: nil)
        session.dataTaskResultResponse = response
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupMaps302ToError() {
        session.dataTaskResultError = nil
        session.dataTaskResultData = makeArbitraryResponseData()
        
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
        session.dataTaskResultResponse = response
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
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
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
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
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
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
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
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
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsErrorIfResponseContainsInvalidVersionNumber() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = makeResponseWithStatus200()
        session.dataTaskResultData = makeResponseDataWithInvalidVersionNumber()
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case .failure = result { expectsError.fulfill() }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupPassesThroughErrorsThrownByTheParser() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = makeResponseWithStatus200()
        session.dataTaskResultData = makeResponseDataWithUnsupportedFormat()
        
        parser.parseVersionStringError = AppStoreLookupResultParserError.unsupportedFormat
        
        let expectsError = expectation(description: "Returns error")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case let .failure(error) = result {
                if (error as? AppStoreLookupResultParserError) == .unsupportedFormat {
                    expectsError.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_PerformLookupReturnsVersionNumberParsedFromTheResponse() {
        session.dataTaskResultError = nil
        session.dataTaskResultResponse = makeResponseWithStatus200()
        session.dataTaskResultData = makeValidResponseData()
        
        let expectedVersionNumber = VersionNumber(majorVersion: 1, minorVersion: 2, patchVersion: 3)
        parser.parseVersionStringResult = "1.2.3"
        
        let expectsSuccess = expectation(description: "Returns version number")
        
        sut.performLookup(withBundleIdentifier: "com.example.test") { result in
            if case let .versionNumber(versionNumber) = result, versionNumber == expectedVersionNumber {
                expectsSuccess.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_LookupSketchBreakerVersionNumber() {
        let bundleID = "com.FDGEntertainment.SketchBreaker"
        
        let expectTheUnexpected = expectation(description: "Looks up Sketch Breaker version number")
        
        liveLookup = AppStoreVersionNumberLookup()
        liveLookup.performLookup(withBundleIdentifier: bundleID) { (result) in
            if case let .versionNumber(versionNumber) = result {
                // Current version is 1.5.0
                if versionNumber == VersionNumber(majorVersion: 1, minorVersion: 5, patchVersion: 0) {
                    expectTheUnexpected.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    private func makeResponseWithStatus200() -> URLResponse {
        let url = URL(string: "com.example.test")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        return response
    }
    
    private func makeResponseDataWithUnsupportedFormat() -> Data {
        let json = [String: Any]()
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        return data
    }
    
    private func makeResponseDataWithInvalidVersionNumber() -> Data {
        return makeResponseData(versionNumberString: "invalid")
    }
    
    private func makeValidResponseData() -> Data {
        return makeResponseData(versionNumberString: "1.0")
    }
    
    private func makeResponseData(versionNumberString: String) -> Data {
        let json: [String: Any] = [
            "resultCount": 1,
            "results": [
                "version": versionNumberString
            ]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        return data
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
        if let error = parseVersionStringError { throw error }
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
