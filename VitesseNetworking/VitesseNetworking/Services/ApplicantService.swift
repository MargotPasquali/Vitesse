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
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

public final class RemoteApplicantService: ApplicantService {
    
    private static let url = URL(string: "http://127.0.0.1:8080")!
    public let networkManager: NetworkManagerProtocol
    
    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    public func getAllCandidates() async throws -> [ApplicantDetail] {
        let request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate"))
        
        let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        guard response.statusCode == 200 else {
            throw ApplicantServiceError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([ApplicantDetail].self, from: data)
        } catch let decodingError as DecodingError {
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }
    
    public func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail] {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = ApplicantCreationRequest(email: email, note: note, linkedinURL: linkedinURL, firstName: firstName, lastName: lastName, phone: phone)
        request.httpBody = try JSONEncoder().encode(credentials)
        
        let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        guard response.statusCode == 200 else {
            throw ApplicantServiceError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([ApplicantDetail].self, from: data)
        } catch let decodingError as DecodingError {
            throw ApplicantServiceError.decodingError(decodingError)
        }
    }
    
    public func deleteCandidate(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        guard response.statusCode == 200 else {
            throw ApplicantServiceError.invalidResponse
        }
    }
    
    public func putCandidateAsFavorite(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)/favorite"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        guard response.statusCode == 200 else {
            throw ApplicantServiceError.invalidResponse
        }
    }
    
    public func updateCandidateDetails(applicant: ApplicantDetail) async throws {
        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("/candidate/\(applicant.id)"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(applicant)
        
        let (_, response) = try await networkManager.data(for: request, authenticatedRequest: true)
        
        guard response.statusCode == 200 else {
            throw ApplicantServiceError.invalidResponse
        }
    }
}
