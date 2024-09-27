//
//  MockProtocol.swift
//  VitesseTestUtilities
//
//  Created by Margot Pasquali on 25/09/2024.
//

import Foundation

// MARK: - MockProtocol

public class MockProtocol: URLProtocol {
    
    // MARK: - Static Properties
    
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    public static var error: Error?
    
    // MARK: - URLProtocol Overrides
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        if let error = MockProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = MockProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() {}
}
