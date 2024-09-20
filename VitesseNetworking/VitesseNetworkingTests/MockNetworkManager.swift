//
//  VitesseNetworkingTests.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 05/09/2024.
//

import XCTest
@testable import VitesseNetworking
@testable import Vitesse

// MARK: - MockNetworkManager

public final class MockNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Mock Properties
    
    public var token: String?
    public var responseData: Data?
    public var response: HTTPURLResponse?
    public var error: Error?
    
    // MARK: - NetworkManagerProtocol Methods
    
    public func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse) {
        if let error = error {
            throw AuthenticationServiceError.networkError(error)
        }
        
        guard let response = response, let responseData = responseData else {
            throw AuthenticationServiceError.invalidResponse
        }
        
        return (responseData, response)
    }
    
    public func set(token: String) {
        self.token = token
    }
}
