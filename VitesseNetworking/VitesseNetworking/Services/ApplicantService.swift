//
//  ApplicantService.swift
//  VitesseNetworking
//
//  Created by Margot Pasquali on 05/09/2024.
//

import Foundation
import VitesseModels

public protocol ApplicantService {
    var networkManager: NetworkManagerProtocol { get }
    func getAllCandidates() async throws -> [ApplicantDetail]
    func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail]
    func deleteCandidate(applicant: ApplicantDetail) async throws
    func putCandidateAsFavorite(applicant: ApplicantDetail) async throws
    func updateCandidateDetails(applicant: ApplicantDetail) async throws
}

public enum ApplicantServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError(Int, message: String)  // Inclure le code d'état et un message personnalisé
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}


public final class RemoteApplicantService: ApplicantService {

    private static let baseURL = URL(string: "http://127.0.0.1:8080")!
    public let networkManager: NetworkManagerProtocol

    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - Fetch All Candidates

    public func getAllCandidates() async throws -> [ApplicantDetail] {
        let request = URLRequest(url: RemoteApplicantService.baseURL.appendingPathComponent("/candidate"))

        let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        try validateResponse(response)

        do {
            return try JSONDecoder().decode([ApplicantDetail].self, from: data)
        } catch let decodingError as DecodingError {
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }

    // MARK: - Add New Candidate

    public func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail] {
        var request = URLRequest(url: RemoteApplicantService.baseURL.appendingPathComponent("/candidate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newCandidate = ApplicantCreationRequest(email: email, note: note, linkedinURL: linkedinURL, firstName: firstName, lastName: lastName, phone: phone)
        request.httpBody = try JSONEncoder().encode(newCandidate)

        let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        try validateResponse(response)

        do {
            return try JSONDecoder().decode([ApplicantDetail].self, from: data)
        } catch let decodingError as DecodingError {
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }

    // MARK: - Delete Candidate

    public func deleteCandidate(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.baseURL.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        try validateResponse(response)
    }

    // MARK: - Toggle Favorite Status

    public func putCandidateAsFavorite(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.baseURL.appendingPathComponent("/candidate/\(applicant.id)/favorite"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        try validateResponse(response)
    }

    // MARK: - Update Candidate Details

    public func updateCandidateDetails(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.baseURL.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(applicant)

        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        try validateResponse(response)
    }

    // MARK: - Helper Methods

    private func validateResponse(_ response: HTTPURLResponse) throws {
        guard (200...299).contains(response.statusCode) else {
            if (500...599).contains(response.statusCode) {
                switch response.statusCode {
                case 502:
                    throw ApplicantServiceError.serverError(502, message: "Mauvaise passerelle. Le serveur a des problèmes.")
                default:
                    throw ApplicantServiceError.serverError(response.statusCode, message: "Erreur serveur avec le code \(response.statusCode).")
                }
            } else {
                throw ApplicantServiceError.invalidResponse
            }
        }
    }




}
