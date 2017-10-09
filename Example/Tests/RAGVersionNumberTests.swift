import UIKit
import XCTest
import RAGVersionNumber

class RAGVersionNumberTests: XCTestCase {
    
    func test_Initializer() {
        let versionNumber = VersionNumber(majorVersion: 1, minorVersion: 2, patchVersion: 3)
        XCTAssertEqual(versionNumber.majorVersion, 1)
        XCTAssertEqual(versionNumber.minorVersion, 2)
        XCTAssertEqual(versionNumber.patchVersion, 3)
    }
    
    func test_PatchVersionDefaultsToZero() {
        let versionNumber = VersionNumber(majorVersion: 1, minorVersion: 2)
        XCTAssertEqual(versionNumber.majorVersion, 1)
        XCTAssertEqual(versionNumber.minorVersion, 2)
        XCTAssertEqual(versionNumber.patchVersion, 0)
    }
    
    func test_MinorVersionDefaultsToZero() {
        let versionNumber = VersionNumber(majorVersion: 1)
        XCTAssertEqual(versionNumber.majorVersion, 1)
        XCTAssertEqual(versionNumber.minorVersion, 0)
        XCTAssertEqual(versionNumber.patchVersion, 0)
    }
    
    func test_StringInitializer() {
        let versionNumber = VersionNumber(string: "1.0.0")
        XCTAssertNotNil(versionNumber)
    }
    
    func test_VersionNumberOfEmptyStringIsNil() {
        let versionNumber = VersionNumber(string: "")
        XCTAssertNil(versionNumber)
    }
    
    func test_StringInitializerParsesMajorVersion() {
        let versionNumber = VersionNumber(string: "1")
        XCTAssertEqual(versionNumber?.majorVersion, 1)
    }
    
    func test_StringInitializerParsesMinorVersion() {
        let versionNumber = VersionNumber(string: "1.2")
        XCTAssertEqual(versionNumber?.minorVersion, 2)
    }
    
    func test_StringInitializerParsesPatchVersion() {
        let versionNumber = VersionNumber(string: "1.2.3")
        XCTAssertEqual(versionNumber?.patchVersion, 3)
    }
    
    func test_StringInitializer_PatchVersionDefaultsToZero() {
        let versionNumber = VersionNumber(string: "1.2")
        XCTAssertEqual(versionNumber?.patchVersion, 0)
    }
    
    func test_StringInitializer_MinorVersionDefaultsToZero() {
        let versionNumber = VersionNumber(string: "1")
        XCTAssertEqual(versionNumber?.minorVersion, 0)
    }
    
    func test_StringInitializer_IgnoresCharactersOtherThanDigitsAndStops() {
        let versionNumber = VersionNumber(string: "1a.2b.3c ")
        XCTAssertEqual(versionNumber?.majorVersion, 1)
        XCTAssertEqual(versionNumber?.minorVersion, 2)
        XCTAssertEqual(versionNumber?.patchVersion, 3)
    }
        
    func test_BundleInitializerReturnsNilIfInfoDictionaryIsNil() {
        struct TestBundle: RAGInfoDictionaryProviding {
            
            var infoDictionary: [String : Any]? = nil
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNil(versionNumber)
    }
    
    func test_BundleInitializerReturnsNilIfInfoDictionaryDoesNotContainCFBundleShortVersionString() {
        struct TestBundle: RAGInfoDictionaryProviding {
            
            var infoDictionary: [String : Any]? = [:]
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNil(versionNumber)
    }
    
    func test_BundleInitializerReturnsValueIfInfoDictionaryContainsCFBundleShortVersionString() {
        struct TestBundle: RAGInfoDictionaryProviding {
            
            var infoDictionary: [String : Any]? = ["CFBundleShortVersionString": "1.2.3"]
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNotNil(versionNumber)
    }
    
    func test_BundleInitializerParsesCFBundleShortVersionString() {
        struct TestBundle: RAGInfoDictionaryProviding {
            
            var infoDictionary: [String : Any]? = ["CFBundleShortVersionString": "1.2.3"]
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertEqual(versionNumber?.majorVersion, 1)
        XCTAssertEqual(versionNumber?.minorVersion, 2)
        XCTAssertEqual(versionNumber?.patchVersion, 3)
    }
    
    func test_Equality() {
        let v1 = VersionNumber(string: "1.2.3")
        let v2 = VersionNumber(string: "1.2.3")
        let areEqual = v1 == v2
        XCTAssertTrue(areEqual)
    }
    
    func test_Inequality() {
        let v1 = VersionNumber(string: "1.2.3")
        let v2 = VersionNumber(string: "1.0.0")
        let areNotEqual = v1 != v2
        XCTAssertTrue(areNotEqual)
    }
    
    func test_CompareVersionNumbersInAscendingOrder() {
        let v1 = VersionNumber(string: "1.2.3")!
        let v2 = VersionNumber(string: "1.2.4")!
        XCTAssertTrue(v1 < v2)
    }
    
    func test_CompareVersionNumbersInDescendingOrder() {
        let v1 = VersionNumber(string: "1.2.3")!
        let v2 = VersionNumber(string: "1.2.2")!
        XCTAssertFalse(v1 < v2)
    }
}
