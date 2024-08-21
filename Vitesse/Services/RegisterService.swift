//
//  RegisterService.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

protocol RegisterService {
    var networkManager: NetworkManagerProtocol { get }
    init(networkManager: NetworkManagerProtocol)
}

enum RegisterServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

final class RemoteRegisterService: RegisterService {
    
    private static let url = URL(string: "http://127.0.0.1:8080")!
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func createNewAccount(username: String, password: String, firstName: String, lastName: String) async throws {
        guard !username.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw AuthenticationServiceError.invalidCredentials
        }
        
        var request = URLRequest(url: RemoteRegisterService.url.appendingPathComponent("/user/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = RegisterRequest(username: username, password: password, firstName: firstName, lastName: lastName)
        request.httpBody = try JSONEncoder().encode(credentials)
    }
    
}
