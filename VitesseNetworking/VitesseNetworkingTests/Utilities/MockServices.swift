//
//  MockServices.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 20/09/2024.
//

import XCTest
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
    
    // MARK: - Properties
    
    public var networkManager: NetworkManagerProtocol
    public var error: RegisterServiceError?
    
    // MARK: - Initializer
    
    public required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - RegisterService Methods
    
    public func createNewAccount(email: String, password: String, firstName: String, lastName: String) async throws {
        if let error = error {
            throw error
        }
        
        // Simule une réponse réussie sans erreur.
        print("Account successfully created for \(email)")
    }
}

// MARK: - MockApplicantService

public final class MockApplicantService: ApplicantService {
    
    // MARK: - Properties
    
    public var networkManager: NetworkManagerProtocol
    public var applicantList: [ApplicantDetail] = []
    public var error: ApplicantServiceError?
    
    // MARK: - Initializer
    
    public required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - ApplicantService Methods
    
    public func getAllCandidates() async throws -> [ApplicantDetail] {
        if let error = error {
            throw error
        }
        
        return applicantList
    }
    
    public func postNewCandidate(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) async throws -> [ApplicantDetail] {
        if let error = error {
            throw error
        }
        
        let newApplicant = ApplicantDetail(id: UUID(), firstName: firstName, lastName: lastName, email: email, phone: phone, linkedinURL: linkedinURL, note: note, isFavorite: false)
        applicantList.append(newApplicant)
        
        return applicantList
    }
    
    public func deleteCandidate(applicant: ApplicantDetail) async throws {
        if let error = error {
            throw error
        }
        
        applicantList.removeAll { $0.id == applicant.id }
    }
    
    public func putCandidateAsFavorite(applicant: ApplicantDetail) async throws {
        if let error = error {
            throw error
        }
        
        if let index = applicantList.firstIndex(where: { $0.id == applicant.id }) {
            applicantList[index].isFavorite.toggle()
        }
    }
    
    public func updateCandidateDetails(applicant: ApplicantDetail) async throws {
        if let error = error {
            throw error
        }
        
        if let index = applicantList.firstIndex(where: { $0.id == applicant.id }) {
            applicantList[index] = applicant
        }
    }
}
