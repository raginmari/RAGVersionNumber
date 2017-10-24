//
//  Protocols.swift
//  Pods
//
//  Created by Reimar Twelker on 21.10.17.
//
//

import Foundation

// Define protocol for URLSession
public protocol URLSessionProtocol {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

// Make URLSession conform to the protocol
extension URLSession: URLSessionProtocol {
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let result = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        
        return result as URLSessionDataTaskProtocol
    }
}

// Define protocol for URLSessionDataTask
public protocol URLSessionDataTaskProtocol {
    
    func resume()
}

// Make URLSessionDataTask conform to the protocol
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
