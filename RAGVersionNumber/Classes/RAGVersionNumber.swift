//
//  RAGVersionNumber.swift
//  Pods
//
//  Created by Reimar Twelker on 09.10.17.
//
//

import Foundation

public struct VersionNumber {
    
    private static let pattern = "[0-9]+([.][0-9]+){0,2}"
    
    public let majorVersion: Int
    public let minorVersion: Int
    public let patchVersion: Int
    
    public init(majorVersion: Int, minorVersion: Int = 0, patchVersion: Int = 0) {
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.patchVersion = patchVersion
    }
    
    public init?(string: String) {
        let validCharacters = CharacterSet.decimalDigits.union(CharacterSet.init(charactersIn: "."))
        let sanitizedString = string.removingCharactersNotInSet(validCharacters)
        
        guard let appVersionRange = sanitizedString.range(of: VersionNumber.pattern, options: .regularExpression) else {
            return nil
        }
        
        let appVersionString = sanitizedString.substring(with: appVersionRange)
        let components = appVersionString.components(separatedBy: ".").map({ Int($0) ?? 0 }).prefix(3)
        
        var major = 0, minor = 0, patch = 0
        switch components.count {
        case 3:
            patch = components[2]
            fallthrough
        case 2:
            minor = components[1]
            fallthrough
        case 1:
            major = components[0]
        default:
            assertionFailure()
            return nil
        }
        
        self.majorVersion = major
        self.minorVersion = minor
        self.patchVersion = patch
    }
}

public protocol RAGInfoDictionaryProviding {
    
    var infoDictionary: [String: Any]? { get }
}

extension Bundle: RAGInfoDictionaryProviding {}

extension VersionNumber {
    
    public init?(bundle: RAGInfoDictionaryProviding) {
        guard let infoDictionary = bundle.infoDictionary else { return nil }
        
        guard let appVersionString = infoDictionary["CFBundleShortVersionString"] as? String else {
            return nil
        }
        
        self.init(string: appVersionString)
    }
}

extension VersionNumber: Comparable {

    public static func == (lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        guard lhs.majorVersion == rhs.majorVersion else { return false }
        guard lhs.minorVersion == rhs.minorVersion else { return false }
        guard lhs.patchVersion == rhs.patchVersion else { return false }
        return true
    }
    
    public static func < (lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        guard lhs.majorVersion <= rhs.majorVersion else { return false }
        guard lhs.minorVersion <= rhs.minorVersion else { return false }
        guard lhs.patchVersion <= rhs.patchVersion else { return false }
        return lhs != rhs
    }
}

private extension String {
    
    func removingCharactersNotInSet(_ characterSet: CharacterSet) -> String {
        let filteredUnicodeScalars = unicodeScalars.filter { characterSet.contains($0) }
        let string = filteredUnicodeScalars.reduce("") { (partial, next) in partial.appending(String(next)) }
        
        return string
    }
}
