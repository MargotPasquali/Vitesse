//
//  RegisterService.swift
//  VitesseNetworking
//
//  Created by Margot Pasquali on 05/09/2024.
//

import Foundation
import VitesseModels

public protocol RegisterService {
    var networkManager: NetworkManagerProtocol { get }
    init(networkManager: NetworkManagerProtocol)
}

public enum RegisterServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

public final class RemoteRegisterService: RegisterService {
    
    private static let url = URL(string: "http://127.0.0.1:8080")!
    public let networkManager: NetworkManagerProtocol
    
    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    public func createNewAccount(username: String, password: String, firstName: String, lastName: String) async throws {
        guard !username.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw RegisterServiceError.invalidCredentials
        }
        
        var request = URLRequest(url: RemoteRegisterService.url.appendingPathComponent("/user/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = RegisterRequest(username: username, password: password, firstName: firstName, lastName: lastName)
        request.httpBody = try JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: false)
            
            guard response.statusCode == 200 else {
                throw RegisterServiceError.invalidResponse
            }
            
            print("Account created successfully: \(String(data: data, encoding: .utf8) ?? "")")
        } catch {
            throw RegisterServiceError.networkError(error)
        }
    }
}
