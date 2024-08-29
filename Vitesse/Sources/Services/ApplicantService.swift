//
//  ApplicantService.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

protocol ApplicantService {
    var networkManager: NetworkManagerProtocol { get }
    func getAllCandidates() async throws -> [ApplicantDetail]

}

enum ApplicantServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

final class RemoteApplicantService: ApplicantService {
    
    private static let url = URL(string: "http://127.0.0.1:8080")!
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getAllCandidates() async throws -> [ApplicantDetail] {
        let request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate"))

        // Debug: Afficher l'URL de la requête
        print("Sending request to URL: \(request.url?.absoluteString ?? "No URL")")
        
        // Debug: Avant d'envoyer la requête, vérifions si un token est disponible
        if let token = networkManager.token {
            print("Token found: \(token)")
        } else {
            print("No token found before sending request")
        }
        
        let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        print("Received response: \(response.statusCode)")
        print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        guard response.statusCode == 200 else {
            print("Non-200 status code received: \(response.statusCode)")
            if response.statusCode == 401 {
                throw ApplicantServiceError.unauthorized
            } else if response.statusCode >= 500 {
                throw ApplicantServiceError.serverError
            } else {
                throw ApplicantServiceError.invalidResponse
            }
        }
        
        do {
            let applicantList = try JSONDecoder().decode([ApplicantDetail].self, from: data)
            print("Decoded account detail: \(applicantList)")
            return applicantList
        } catch let decodingError as DecodingError {
            print("Caught DecodingError: \(decodingError)")
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }

}
