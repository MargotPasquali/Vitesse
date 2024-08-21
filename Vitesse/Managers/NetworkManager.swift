//
//  NetworkManager.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

protocol NetworkManagerProtocol {
    var token: String? { get set }
    func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse)
    func set(token: String)
}

final class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    
    private var urlSession: URLSession
    
    var token: String?
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func set(token: String) {
        guard !token.isEmpty else { return }
        self.token = token
    }
    
    func data(for request: URLRequest, authenticatedRequest: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var customRequest = request
        
        if authenticatedRequest {
            guard let token = token else {
                throw AuthenticationServiceError.missingToken
            }
            customRequest.setValue(token, forHTTPHeaderField: "token")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: customRequest, delegate: nil)
            
            guard let response = response as? HTTPURLResponse else {
                throw AuthenticationServiceError.invalidResponse
            }
            
            switch response.statusCode {
            case 200:
                return (data, response)
            case 401:
                throw AuthenticationServiceError.unauthorized
            case 500...599:
                throw AuthenticationServiceError.serverError
            default:
                throw AuthenticationServiceError.invalidResponse
            }
        } catch let error as URLError {
            print("Caught URLError: \(error)")
            throw AuthenticationServiceError.networkError(error)
        } catch {
            print("Caught generic error: \(error)")
            throw AuthenticationServiceError.networkError(error)
        }
    }
}
