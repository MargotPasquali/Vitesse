//
//  ApplicantServiceTests.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 27/09/2024.
//

@testable import VitesseNetworking

import XCTest
import VitesseModels
import VitesseTestUtilities

final class ApplicantServiceTests: XCTestCase {

    var applicantService: ApplicantService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()

        // Initialisation du MockNetworkManager
        mockNetworkManager = MockNetworkManager()

        // Initialisation du service avec le MockNetworkManager
        applicantService = RemoteApplicantService(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        applicantService = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    // MARK: - Test Get All Candidates (Success)

    func testGetAllCandidates_Success() async throws {
        // Given
        let jsonData = FakeResponseData.getAllCandidatesCorrectData
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        mockNetworkManager.simulatedResponse = (jsonData, response)

        // When
        let candidates = try await applicantService.getAllCandidates()

        // Then
        XCTAssertEqual(candidates.count, 2, "Deux candidats devraient être récupérés.")
        XCTAssertEqual(candidates[0].firstName, "Martin", "Le premier candidat devrait être 'Martin'.")
    }

    // MARK: - Test Get All Candidates (Server Error)

    func testGetAllCandidates_ServerError() async throws {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        mockNetworkManager.simulatedResponse = (Data(), response)

        // When / Then
        do {
            _ = try await applicantService.getAllCandidates()
            XCTFail("L'appel devrait échouer avec une erreur de serveur.")
        } catch ApplicantServiceError.serverError(let code, let message) {
            XCTAssertEqual(code, 500, "Le code d'erreur devrait être 500.")
            XCTAssertEqual(message, "Erreur serveur avec le code 500.", "Le message d'erreur devrait correspondre.")
        }
    }

    // MARK: - Test Post New Candidate (Success)

    func testPostNewCandidate_Success() async throws {
        // Given
        let jsonData = FakeResponseData.postNewCandidateCorrectData
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate")!, statusCode: 201, httpVersion: nil, headerFields: nil)!

        mockNetworkManager.simulatedResponse = (jsonData, response)

        // When
        let candidates = try await applicantService.postNewCandidate(
            email: "john.doe@example.com",
            note: "New candidate",
            linkedinURL: "https://linkedin.com/in/johndoe",
            firstName: "John",
            lastName: "Doe",
            phone: "0712345678"
        )

        // Then
        XCTAssertEqual(candidates.count, 1, "Un candidat devrait être renvoyé.")
        XCTAssertEqual(candidates[0].firstName, "John", "Le candidat devrait être 'John'.")
    }

    // MARK: - Test Delete Candidate (Success)

    func testDeleteCandidate_Success() async throws {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate/1")!, statusCode: 204, httpVersion: nil, headerFields: nil)!

        mockNetworkManager.simulatedResponse = (Data(), response)

        // When / Then
        do {
            let candidate = FakeResponseData.fakeApplicant
            try await applicantService.deleteCandidate(applicant: candidate)
        } catch {
            XCTFail("La suppression du candidat devrait réussir.")
        }
    }

    // MARK: - Test Put Candidate As Favorite (Success)

    func testPutCandidateAsFavorite_Success() async throws {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate/1/favorite")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        mockNetworkManager.simulatedResponse = (Data(), response)

        // When / Then
        do {
            let candidate = FakeResponseData.fakeApplicant
            try await applicantService.putCandidateAsFavorite(applicant: candidate)
        } catch {
            XCTFail("Le basculement du statut favori devrait réussir.")
        }
    }

    // MARK: - Test Update Candidate Details (Success)

    func testUpdateCandidateDetails_Success() async throws {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/candidate/1")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        mockNetworkManager.simulatedResponse = (Data(), response)

        // When / Then
        do {
            let candidate = FakeResponseData.fakeApplicant
            try await applicantService.updateCandidateDetails(applicant: candidate)
        } catch {
            XCTFail("La mise à jour des détails du candidat devrait réussir.")
        }
    }
}
