//
// Copyright (C) 2024 Vitesse
//

import Foundation

public protocol RegisterService {
    var networkManager: NetworkManagerProtocol { get }
    func createNewAccount(email: String, password: String, firstName: String, lastName: String) async throws
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
    
    public func createNewAccount(email: String, password: String, firstName: String, lastName: String) async throws {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw RegisterServiceError.invalidCredentials
        }
        
        var request = URLRequest(url: RemoteRegisterService.url.appendingPathComponent("/user/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = RegisterRequest(email: email, password: password, firstName: firstName, lastName: lastName)
        request.httpBody = try JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: false)
            print("Received data from network.")
            
            guard response.statusCode == 200 else {
                print("Received error response: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw RegisterServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw RegisterServiceError.serverError
                } else {
                    throw RegisterServiceError.invalidResponse
                }
            }
            
        } catch let error as RegisterServiceError {
            throw error
        } catch let urlError as URLError {
            print("Caught URLError: \(urlError)")
            throw RegisterServiceError.networkError(urlError)
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw RegisterServiceError.decodingError(decodingError)
        } catch {
            print("Caught unknown error: \(error)")
            throw RegisterServiceError.unknown
        }
    }
}
