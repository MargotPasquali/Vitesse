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
    func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail]
    func deleteCandidate(applicant: ApplicantDetail) async throws
    func putCandidateAsFavorite(applicant: ApplicantDetail) async throws
    func updateCandidateDetails(applicant: ApplicantDetail) async throws
    
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
    
    func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail] {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Crée une instance de ApplicantCreationRequest en utilisant les arguments de la fonction
        let credentials = ApplicantCreationRequest(email: email, note: note, linkedinURL: linkedinURL, firstName: firstName, lastName: lastName, phone: phone)
        request.httpBody = try JSONEncoder().encode(credentials)
        
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
            let newApplicantList = try JSONDecoder().decode([ApplicantDetail].self, from: data)
            print("Decoded account detail: \(newApplicantList)")
            return newApplicantList
        } catch let decodingError as DecodingError {
            print("Caught DecodingError: \(decodingError)")
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }
    
    func deleteCandidate(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    }
    
    func putCandidateAsFavorite(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)/favorite"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    }
    
    func updateCandidateDetails(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Sérialisation des informations mises à jour
        let updatedApplicantData = try JSONEncoder().encode(applicant)
        request.httpBody = updatedApplicantData
        
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
    }
    
}
