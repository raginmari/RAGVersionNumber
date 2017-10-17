//
//  URL+RAGAppStoreLookupTests.swift
//  RAGVersionNumber
//
//  Created by Reimar Twelker on 15.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import RAGVersionNumber

class URL_RAGAppStoreLookupTests: XCTestCase {
    
    func test_AppStoreLookupURL() {
        let url = URL.appStoreLookupURL(bundleIdentifier: "com.example.test", appStoreCountryCode: "de")
        XCTAssertNotNil(url)
    }
    
    func test_AppStoreLookupURLUsesGivenCountryCode() {
        let url = URL.appStoreLookupURL(bundleIdentifier: "com.example.test", appStoreCountryCode: "de")
        let queryParameters = url!.query!.components(separatedBy: "&")
        
        XCTAssertNotNil(queryParameters.first { (parameter) in
            let components = parameter.components(separatedBy: "=")
            return components[0] == "country" && components[1] == "de"
        })
    }
    
    func test_AppStoreLookupURLUsesGivenBundleIdentifier() {
        let url = URL.appStoreLookupURL(bundleIdentifier: "com.example.test", appStoreCountryCode: "de")
        let queryParameters = url!.query!.components(separatedBy: "&")
        
        XCTAssertNotNil(queryParameters.first { (parameter) in
            let components = parameter.components(separatedBy: "=")
            return components[0] == "bundleId" && components[1] == "com.example.test"
        })
    }
    
    func test_AppStoreLookupURLDefaultCountryCodeIsUS() {
        let url = URL.appStoreLookupURL(bundleIdentifier: "com.example.test")
        let queryParameters = url!.query!.components(separatedBy: "&")
        
        XCTAssertNotNil(queryParameters.first { (parameter) in
            let components = parameter.components(separatedBy: "=")
            return components[0] == "country" && components[1] == "us"
        })
    }
}
