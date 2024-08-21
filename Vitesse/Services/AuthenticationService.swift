//
//  AuthenticationService.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

protocol AuthenticationService {
    var networkManager: NetworkManagerProtocol { get }
    init(networkManager: NetworkManagerProtocol)
    func authenticate(username: String, password: String) async throws
}

enum AuthenticationServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

final class RemoteAuthenticationService: AuthenticationService {
    
    private static let url = URL(string: "http://127.0.0.1:8080")!
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func authenticate(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthenticationServiceError.invalidCredentials
        }
        
        var request = URLRequest(url: RemoteAuthenticationService.url.appendingPathComponent("/user/auth"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = AuthenticationRequest(username: username, password: password)
        request.httpBody = try JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: false)
            print("Received data from network.")
            
            guard response.statusCode == 200 else {
                print("Received error response: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw AuthenticationServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw AuthenticationServiceError.serverError
                } else {
                    throw AuthenticationServiceError.invalidResponse
                }
            }
            
            let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
            print("Decoded authentication response: \(authenticationResponse)")
            
            if authenticationResponse.token == "INVALID_TOKEN" {
                print("Unauthorized token received.")
                throw AuthenticationServiceError.unauthorized
            }
            
            networkManager.set(token: authenticationResponse.token)
            let isAdmin = authenticationResponse.isAdmin

            
        } catch let error as AuthenticationServiceError {
            throw error
        } catch let urlError as URLError {
            print("Caught URLError: \(urlError)")
            throw AuthenticationServiceError.networkError(urlError)
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw AuthenticationServiceError.decodingError(decodingError)
        } catch {
            print("Caught unknown error: \(error)")
            throw AuthenticationServiceError.unknown
        }
    }
}
