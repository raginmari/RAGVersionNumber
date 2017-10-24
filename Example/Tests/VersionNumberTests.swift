import UIKit
import XCTest
import RAGVersionNumber

class VersionNumberTests: XCTestCase {
    
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
        struct TestBundle: BundleProtocol {
            
            var infoDictionary: [String : Any]? = nil
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNil(versionNumber)
    }
    
    func test_BundleInitializerReturnsNilIfInfoDictionaryDoesNotContainCFBundleShortVersionString() {
        struct TestBundle: BundleProtocol {
            
            var infoDictionary: [String : Any]? = [:]
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNil(versionNumber)
    }
    
    func test_BundleInitializerReturnsValueIfInfoDictionaryContainsCFBundleShortVersionString() {
        struct TestBundle: BundleProtocol {
            
            var infoDictionary: [String : Any]? = ["CFBundleShortVersionString": "1.2.3"]
        }
        
        let versionNumber = VersionNumber(bundle: TestBundle())
        XCTAssertNotNil(versionNumber)
    }
    
    func test_BundleInitializerParsesCFBundleShortVersionString() {
        struct TestBundle: BundleProtocol {
            
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
    
    func test_IsPatchSuccessor() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "1.2.3")!
        XCTAssertTrue(v2.isPatchSuccessor(of: v1))
        
        let v3 = VersionNumber(string: "1.2.10")!
        XCTAssertTrue(v3.isPatchSuccessor(of: v1))
    }
    
    func test_IsPatchSuccessorWithEqualVersion() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "1.2.2")!
        XCTAssertFalse(v2.isPatchSuccessor(of: v1))
    }
    
    func test_IsPatchSuccessorWithPatchPredecessorVersion() {
        let v1 = VersionNumber(string: "1.2.3")!
        let v2 = VersionNumber(string: "1.2.2")!
        XCTAssertFalse(v2.isPatchSuccessor(of: v1))
    }
    
    func test_IsPatchSuccessorWithMinorSuccessorVersion() {
        let v1 = VersionNumber(string: "1.2.1")!
        let v2 = VersionNumber(string: "1.3.2")!
        XCTAssertFalse(v2.isPatchSuccessor(of: v1))
    }
    
    func test_IsPatchSuccessorWithMajorSuccessorVersion() {
        let v1 = VersionNumber(string: "1.2.1")!
        let v2 = VersionNumber(string: "2.2.2")!
        XCTAssertFalse(v2.isPatchSuccessor(of: v1))
    }
    
    func test_IsMinorSuccessor() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "1.3.2")!
        XCTAssertTrue(v2.isMinorSuccessor(of: v1))
        
        let v3 = VersionNumber(string: "1.3")!
        XCTAssertTrue(v3.isMinorSuccessor(of: v1))
        
        let v4 = VersionNumber(string: "1.10.0")!
        XCTAssertTrue(v4.isMinorSuccessor(of: v1))
    }
    
    func test_IsMinorSuccessorWithEqualVersion() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "1.2.2")!
        XCTAssertFalse(v2.isMinorSuccessor(of: v1))
    }
    
    func test_IsMinorSuccessorWithMinorPredecessorVersion() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "1.1.2")!
        XCTAssertFalse(v2.isMinorSuccessor(of: v1))
    }
    
    func test_IsMinorSuccessorWithMajorSuccessor() {
        let v1 = VersionNumber(string: "1.2.2")!
        let v2 = VersionNumber(string: "2.3.2")!
        XCTAssertFalse(v2.isMinorSuccessor(of: v1))
    }
    
    func test_IsMajorSuccessor() {
        let v1 = VersionNumber(string: "1.0.0")!
        let v2 = VersionNumber(string: "2.0.0")!
        XCTAssertTrue(v2.isMajorSuccessor(of: v1))
        
        let v3 = VersionNumber(string: "10.0.0")!
        XCTAssertTrue(v3.isMajorSuccessor(of: v1))
    }
    
    func test_IsMajorSuccessorWithEqualVersion() {
        let v1 = VersionNumber(string: "1.0.0")!
        let v2 = VersionNumber(string: "1.0.0")!
        XCTAssertFalse(v2.isMajorSuccessor(of: v1))
    }
    
    func test_IsMajorSuccessorWithMajorPredecessorVersion() {
        let v1 = VersionNumber(string: "2.0.0")!
        let v2 = VersionNumber(string: "1.0.0")!
        XCTAssertFalse(v2.isMajorSuccessor(of: v1))
    }
}
