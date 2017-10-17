//
//  RAGAppStoreVersionNumberLookup.swift
//  Pods
//
//  Created by Reimar Twelker on 12.10.17.
//
//

import Foundation

// Define protocol for URLSession
public protocol RAGURLSessionProtocol {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RAGURLSessionDataTaskProtocol
}

// Make URLSession conform to the protocol
extension URLSession: RAGURLSessionProtocol {

    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RAGURLSessionDataTaskProtocol {
        let result = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        return result as RAGURLSessionDataTaskProtocol
    }
}

// Define protocol for URLSessionDataTask
public protocol RAGURLSessionDataTaskProtocol {
    
    func resume()
}

// Make URLSessionDataTask conform to the protocol
extension URLSessionDataTask: RAGURLSessionDataTaskProtocol {}

public class RAGAppStoreVersionNumberLookup {
    
    public enum Error: Swift.Error {
        case internalInconsistency
        case http4xx(Int)
        case http5xx(Int)
        case general
    }
    
    private let parser: RAGAppStoreLookupResultParsing
    private let session: RAGURLSessionProtocol
    
    public init(parser: RAGAppStoreLookupResultParsing, session: RAGURLSessionProtocol? = nil) {
        self.parser = parser
        self.session = session ?? URLSession(configuration: URLSessionConfiguration.ephemeral)
    }
    
    public enum Result {
        case versionNumber(VersionNumber)
        case failure(Swift.Error)
    }
    
    public func performLookup(withBundleIdentifier bundleIdentifier: String?, appStoreCountryCode countryCode: String = "us", completion: @escaping (Result) -> Void) {
        guard let bundleIdentifier = bundleIdentifier ?? readBundleIdentifier() else {
            completion(.failure(Error.internalInconsistency))
            return
        }
        
        guard let url = URL.appStoreLookupURL(bundleIdentifier: bundleIdentifier, appStoreCountryCode: countryCode) else {
            completion(.failure(Error.internalInconsistency))
            return
        }
        
        performLookupWithURL(url, completion: completion)
    }
    
    private func performLookupWithURL(_ url: URL, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                completion(.failure(Error.general))
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(.failure(Error.general))
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
                let error = Error.http4xx(statusCode)
                completion(.failure(error))
            case 500...599:
                let error = Error.http5xx(statusCode)
                completion(.failure(error))
            default:
                completion(.failure(Error.general))
            }
            
            return
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]).flatMap({ $0 }) else {
            completion(.failure(Error.general))
            return
        }
        
        handleAppStoreLookupJSON(json, completion: completion)
    }
    
    private func handleAppStoreLookupJSON(_ json: [String: Any], completion: @escaping (Result) -> Void) {
        do {
            let versionString = try self.parser.parseVersionString(fromJSON: json)
            guard let versionNumber = VersionNumber(string: versionString) else {
                completion(.failure(Error.general))
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
