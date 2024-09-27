//
//  MockServices.swift
//  VitesseTestUtilities
//
//  Created by Margot Pasquali on 25/09/2024.
//

import Foundation
@testable import VitesseNetworking
@testable import VitesseModels

// MARK: - MockAuthenticationService

public final class MockAuthenticationService: AuthenticationService {
    
    // MARK: - Properties
    
    public var networkManager: NetworkManagerProtocol
    public var authResponse: AuthenticationResponse?
    public var error: AuthenticationServiceError?
    
    // MARK: - Initializer
    
    public required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - AuthenticationService Methods
    
    public func authenticate(username: String, password: String) async throws {
        if let error = error {
            throw error
        }
        
        if let authResponse = authResponse {
            networkManager.set(token: authResponse.token)
        } else {
            throw AuthenticationServiceError.unknown
        }
    }
}

// MARK: - MockRegisterService

public final class MockRegisterService: RegisterService {
    
    public var networkManager: NetworkManagerProtocol
    public var error: RegisterServiceError?
    
    public init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    public func createNewAccount(email: String, password: String, firstName: String, lastName: String) async throws {
        if let error = error {
            throw error
        }
        
        // Simule une interaction réseau avec le NetworkManager
        let url = URL(string: "http://127.0.0.1:8080/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (_, response) = try await networkManager.data(for: request, authenticatedRequest: false)
            
            if response.statusCode != 200 {
                // Simule une erreur sur les réponses HTTP non 200
                throw RegisterServiceError.invalidResponse
            }
            
            print("Account successfully created for \(email)")
        } catch {
            throw RegisterServiceError.networkError(error)
        }
    }
}


// MARK: - MockApplicantService

public final class MockApplicantService: ApplicantService {
    
    public var networkManager: NetworkManagerProtocol
    public var applicantList: [ApplicantDetail] = []
    public var simulatedError: ApplicantServiceError?  // Pour injecter des erreurs dans les tests
    public var updatedApplicant: ApplicantDetail?
    
    
    public required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    public func getAllCandidates() async throws -> [ApplicantDetail] {
        if let error = simulatedError {
            throw error
        }
        return applicantList
    }
    
    public func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail] {
        if let error = simulatedError {
            throw error
        }
        
        let newApplicant = ApplicantDetail(id: UUID(), firstName: firstName, lastName: lastName, email: email, phone: phone, linkedinURL: linkedinURL, note: note, isFavorite: false)
        applicantList.append(newApplicant)
        
        return applicantList
    }
    
    public func deleteCandidate(applicant: ApplicantDetail) async throws {
        if let error = simulatedError {
            throw error
        }
        
        applicantList.removeAll { $0.id == applicant.id }
    }
    
    public func putCandidateAsFavorite(applicant: ApplicantDetail) async throws {
        if let error = simulatedError {
            throw error
        }

        if let index = applicantList.firstIndex(where: { $0.id == applicant.id }) {
            applicantList[index].isFavorite.toggle()
            print("isFavorite a changé pour \(applicantList[index].isFavorite)")
        }
    }

    
    public func updateCandidateDetails(applicant: ApplicantDetail) async throws {
        if let error = simulatedError {
            throw error
        }
        
        // Enregistrer le candidat mis à jour
        updatedApplicant = applicant
        
        if let index = applicantList.firstIndex(where: { $0.id == applicant.id }) {
            applicantList[index] = applicant
        }
    }
}
