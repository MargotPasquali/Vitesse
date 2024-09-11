//
//  NetworkManager.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

public protocol NetworkManagerProtocol {
    var token: String? { get set }
    func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse)
    func set(token: String)
}

public final class NetworkManager: NetworkManagerProtocol {
    
    public static let shared = NetworkManager()
    
    private var urlSession: URLSession
    
    public var token: String?
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func set(token: String) {
        guard !token.isEmpty else {
            print("Token is empty, not setting it.")
            return
        }
        self.token = token
        print("Token set: \(token)")
    }
    
    public func data(for request: URLRequest, authenticatedRequest: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var customRequest = request
        
        if authenticatedRequest {
            guard let token = token else {
                print("No token available for authenticated request.")
                throw AuthenticationServiceError.missingToken
            }
            customRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Added Authorization header with token: Bearer \(token)")
        } else {
            print("Sending request without authentication")
        }
        
        print("Sending request to URL: \(customRequest.url?.absoluteString ?? "No URL")")
        print("Request method: \(customRequest.httpMethod ?? "No method")")
        if let headers = customRequest.allHTTPHeaderFields {
            print("Request headers: \(headers)")
        }
        if let body = customRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Request body: \(bodyString)")
        } else {
            print("No request body")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: customRequest, delegate: nil)
            
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response received")
                throw AuthenticationServiceError.invalidResponse
            }
            
            print("Received HTTP response with status code: \(response.statusCode)")
            if let responseData = String(data: data, encoding: .utf8) {
                print("Response data: \(responseData)")
            } else {
                print("Unable to decode response data as string")
            }
            
            switch response.statusCode {
            case 200...299:
                // Success case for codes 200 to 299, including 201
                return (data, response)
            case 401:
                print("Unauthorized (401) response received")
                throw AuthenticationServiceError.unauthorized
            case 500...599:
                print("Server error (5xx) response received: \(response.statusCode)")
                throw AuthenticationServiceError.serverError
            default:
                print("Unexpected HTTP status code received: \(response.statusCode)")
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
