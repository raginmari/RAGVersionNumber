//
//  AppStoreVersionNumberLookup.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

public class AppStoreVersionNumberLookup {
    
    /// The session used to perform the iTunes lookup request
    var session: URLSessionProtocol = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    /// The parser used to handle the response of the iTunes lookup request
    var parser: AppStoreLookupResultParsing = AppStoreLookupResultParser()
    
    /// Represents a result of a version number lookup call.
    public enum Result {
        
        /// A successful result associated with the requested version number
        case versionNumber(VersionNumber)
        
        /// A failure associated with an error
        case failure(Error)
    }
    
    /// Asks the iTunes lookup API for the version number of the app with the given bundle ID. 
    /// The given country code is passed as an additional parameter. Its default value is "us".
    ///
    /// - Parameters:
    ///   - bundleIdentifier: the bundle ID of the app whose App Store version should be looked up
    ///   - countryCode: the country code of the App Store that the request should be directed at
    ///   - completion: receives the result of the request
    public func performLookup(withBundleIdentifier bundleIdentifier: String?, appStoreCountryCode countryCode: String = "us", completion: @escaping (Result) -> Void) {
        guard let bundleIdentifier = bundleIdentifier ?? readBundleIdentifier() else {
            completion(.failure(AppStoreVersionNumberLookupError.internalInconsistency))
            return
        }
        
        guard let url = URL.appStoreLookupURL(bundleIdentifier: bundleIdentifier, appStoreCountryCode: countryCode) else {
            completion(.failure(AppStoreVersionNumberLookupError.internalInconsistency))
            return
        }
        
        performLookupWithURL(url, completion: completion)
    }
    
    private func performLookupWithURL(_ url: URL, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                completion(.failure(AppStoreVersionNumberLookupError.general))
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(.failure(AppStoreVersionNumberLookupError.general))
                return
            }
            
            self?.handleAppStoreLookupResponse(response, data: data, completion: completion)
        }
        
        task.resume()
    }
    
    private func handleAppStoreLookupResponse(_ response: HTTPURLResponse, data: Data, completion: @escaping (Result) -> Void) {
        let statusCode = response.statusCode
        guard statusCode == 200 else {
            switch statusCode {
            case 400...499:
                let error = AppStoreVersionNumberLookupError.http4xx(statusCode)
                completion(.failure(error))
            case 500...599:
                let error = AppStoreVersionNumberLookupError.http5xx(statusCode)
                completion(.failure(error))
            default:
                let error = AppStoreVersionNumberLookupError.general
                completion(.failure(error))
            }
            
            return
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]).flatMap({ $0 }) else {
            completion(.failure(AppStoreVersionNumberLookupError.general))
            return
        }
        
        handleAppStoreLookupJSON(json, completion: completion)
    }
    
    private func handleAppStoreLookupJSON(_ json: [String: Any], completion: @escaping (Result) -> Void) {
        do {
            let versionString = try self.parser.parseVersionString(fromJSON: json)
            guard let versionNumber = VersionNumber(string: versionString) else {
                completion(.failure(AppStoreVersionNumberLookupError.general))
                return
            }
            
            completion(.versionNumber(versionNumber))
        } catch {
            // Pass through error thrown by the parser
            completion(.failure(error))
        }
    }
    
    private func readBundleIdentifier() -> String? {
        let bundle = Bundle(for: type(of: self))
        guard let infoDictionary = bundle.infoDictionary else { return nil }
        let bundleIdentifier = infoDictionary["CFBundleIdentifier"] as? String;
        
        return bundleIdentifier
    }
}
