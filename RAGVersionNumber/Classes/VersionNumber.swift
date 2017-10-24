//
//  VersionNumber.swift
//  Pods
//
//  Created by Reimar Twelker on 09.10.17.
//
//

import Foundation

public struct VersionNumber {
    
    private static let pattern = "[0-9]+([.][0-9]+){0,2}"
    
    /// The major component of the version number
    public let majorVersion: Int
    
    /// The minor component of the version number
    public let minorVersion: Int
    
    /// The patch component of the version number
    public let patchVersion: Int
    
    /// Creates a version number using the given components.
    ///
    /// - Parameters:
    ///   - majorVersion: the major component
    ///   - minorVersion: the minor component. Default value is 0.
    ///   - patchVersion: the patch component. Default value is 0.
    public init(majorVersion: Int, minorVersion: Int = 0, patchVersion: Int = 0) {
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.patchVersion = patchVersion
    }
    
    /// Creates a version number from the given string. Fails if the method is
    /// unable to find a version number in the string.
    ///
    /// Examples for valid strings:
    /// - "1" => 1.0.0
    /// - "1.0" => 1.0.0
    /// - "1.2.3.4" => 1.2.3
    /// - "1.2.3a" => 1.2.3
    ///
    /// Valid characters are decimal digits and the dot. All other characters
    /// are removed from the string before the method attempts to find the version number.
    ///
    /// - Parameter string: a string containing a version number
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

extension VersionNumber {
    
    /// Creates a version number by looking at the info dictionary of the given bundle. 
    /// Fails if the bundle does not have an info dicationary or the dictionary does
    /// not contain a value for the key `CFBundleShortVersionString`.
    ///
    /// - Parameter bundle: an app bundle
    public init?(bundle: BundleProtocol) {
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

extension VersionNumber {
    
    /// Returns whether the receiver is at least one patch version ahead of the given 
    /// version number. The major and minor components must be equal.
    ///
    /// - Parameter otherVersionNumber: a version number
    /// - Returns: `true` if the major and minor components of the version numbers are 
    /// equal and the receiver is greater with respect to the patch component
    public func isPatchSuccessor(of otherVersionNumber: VersionNumber) -> Bool {
        guard otherVersionNumber.majorVersion == majorVersion else { return false }
        guard otherVersionNumber.minorVersion == minorVersion else { return false }
        let result = otherVersionNumber.patchVersion < patchVersion
        
        return result
    }
    
    /// Returns whether the receiver is at least one minor version ahead of the given
    /// version number. The major components must be equal. The patch components are ignored.
    ///
    /// - Parameter otherVersionNumber: a version number
    /// - Returns: `true` if the major component of the version numbers are
    /// equal and the receiver is greater with respect to the minor component
    public func isMinorSuccessor(of otherVersionNumber: VersionNumber) -> Bool {
        guard otherVersionNumber.majorVersion == majorVersion else { return false }
        let result = minorVersion > otherVersionNumber.minorVersion
        
        return result
    }
    
    /// Returns whether the receiver is at least one major version ahead of the given
    /// version number. The minor and patch components are ignored.
    ///
    /// - Parameter otherVersionNumber: a version number
    /// - Returns: `true` if the receiver is greater with respect to the major component
    public func isMajorSuccessor(of otherVersionNumber: VersionNumber) -> Bool {
        let result = majorVersion > otherVersionNumber.majorVersion
        
        return result
    }
}

private extension String {
    
    func removingCharactersNotInSet(_ characterSet: CharacterSet) -> String {
        let filteredUnicodeScalars = unicodeScalars.filter { characterSet.contains($0) }
        let string = filteredUnicodeScalars.reduce("") { (partial, next) in partial.appending(String(next)) }
        
        return string
    }
}
