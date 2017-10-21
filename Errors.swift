//
//  AppStoreVersionNumberLookupError.swift
//  Pods
//
//  Created by Reimar Twelker on 21.10.17.
//
//

import Foundation

public enum AppStoreVersionNumberLookupError: Error {
    
    /// An error in the set up of the lookup request has occurred
    case internalInconsistency

    /// The lookup response reports a client error. Associated with the actual status code
    case http4xx(Int)
    
    /// The lookup response reports a server error. Associated with the actual status code
    case http5xx(Int)
    
    /// A general error has occurred
    case general
}

extension AppStoreVersionNumberLookupError: Equatable {
    
    public static func == (lhs: AppStoreVersionNumberLookupError, rhs: AppStoreVersionNumberLookupError) -> Bool {
        switch (lhs, rhs) {
        case (.internalInconsistency, .internalInconsistency):
            return true
            
        case let (.http4xx(lhsStatusCode), .http4xx(rhsStatusCode)):
            return lhsStatusCode == rhsStatusCode
            
        case let (.http5xx(lhsStatusCode), .http5xx(rhsStatusCode)):
            return lhsStatusCode == rhsStatusCode
            
        case (.general, .general):
            return true
            
        case (.internalInconsistency, _),
             (.http4xx, _),
             (.http5xx, _),
             (.general, _):
            return false
        }
    }
}

public enum AppStoreLookupResultParserError: Error {
    
    /// The lookup result has no results or an empty array of results
    case notFound
    
    /// The lookup result has more than one result
    case notUnique
    
    /// The lookup result JSON format is unsupported
    case unsupportedFormat
}
