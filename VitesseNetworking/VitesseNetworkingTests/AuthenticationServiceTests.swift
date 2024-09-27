//
//  AuthenticationServiceTests.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 26/09/2024.
//

import XCTest
@testable import Vitesse
@testable import VitesseModels
@testable import VitesseTestUtilities

final class AuthenticationServiceTests: XCTestCase {
    
    var authenticationService: AuthenticationService!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        
        // Assurez-vous d'initialiser correctement MockNetworkManager avant de l'utiliser.
        mockNetworkManager = MockNetworkManager()
        
        // Initialisez RemoteAuthenticationService avec un MockNetworkManager non optionnel.
        authenticationService = RemoteAuthenticationService(networkManager: mockNetworkManager)
    }

    
    override func tearDown() {
        authenticationService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Test Success
    
    func testAuthenticate_Success() async throws {
        // Given
        let token = "VALID_TOKEN"
        let jsonData = """
        {
            "token": "\(token)",
            "isAdmin": true
        }
        """.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockNetworkManager.simulatedResponse = (jsonData, response)
        
        // When
        try await authenticationService.authenticate(username: "user@example.com", password: "password123")
        
        // Then
        XCTAssertEqual(mockNetworkManager.token, token, "Le token devrait être défini après une authentification réussie.")
    }
    
    // MARK: - Test Invalid Credentials
    
    func testAuthenticate_InvalidCredentials() async throws {
        // Given
        let jsonData = Data()  // Pas de réponse utile attendue
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        
        mockNetworkManager.simulatedResponse = (jsonData, response)
        
        // When / Then
        do {
            try await authenticationService.authenticate(username: "invalid@example.com", password: "wrongpassword")
            XCTFail("L'authentification devrait échouer avec des identifiants invalides.")
        } catch AuthenticationServiceError.unauthorized {
            // Succès attendu
        } catch {
            XCTFail("L'erreur retournée devrait être .unauthorized")
        }
    }
    
    // MARK: - Test Network Error
    
    func testAuthenticate_NetworkError() async throws {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        mockNetworkManager.simulatedError = networkError
        
        // When / Then
        do {
            try await authenticationService.authenticate(username: "user@example.com", password: "password123")
            XCTFail("L'authentification devrait échouer en cas d'erreur réseau.")
        } catch AuthenticationServiceError.networkError(let error as URLError) {
            XCTAssertEqual(error.code, .notConnectedToInternet, "L'erreur réseau devrait correspondre à .notConnectedToInternet")
        } catch {
            XCTFail("L'erreur retournée devrait être .networkError")
        }
    }
    
    // MARK: - Test Server Error (500+)
    
    func testAuthenticate_ServerError() async throws {
        // Given
        let jsonData = Data()  // Pas de réponse utile attendue
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        mockNetworkManager.simulatedResponse = (jsonData, response)
        
        // When / Then
        do {
            try await authenticationService.authenticate(username: "user@example.com", password: "password123")
            XCTFail("L'authentification devrait échouer en cas d'erreur serveur.")
        } catch AuthenticationServiceError.serverError {
            // Succès attendu
        } catch {
            XCTFail("L'erreur retournée devrait être .serverError")
        }
    }
    
    // MARK: - Test Invalid Response
    
    func testAuthenticate_InvalidResponse() async throws {
        // Given
        let invalidData = "invalid json".data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockNetworkManager.simulatedResponse = (invalidData, response)
        
        // When / Then
        do {
            try await authenticationService.authenticate(username: "user@example.com", password: "password123")
            XCTFail("L'authentification devrait échouer en cas de réponse non valide.")
        } catch AuthenticationServiceError.decodingError {
            // Succès attendu
        } catch {
            XCTFail("L'erreur retournée devrait être .decodingError")
        }
    }
    
    // MARK: - Test Missing Credentials
    
    func testAuthenticate_MissingCredentials() async throws {
        // When / Then
        do {
            try await authenticationService.authenticate(username: "", password: "")
            XCTFail("L'authentification devrait échouer avec des identifiants vides.")
        } catch AuthenticationServiceError.invalidCredentials {
            // Succès attendu
        } catch {
            XCTFail("L'erreur retournée devrait être .invalidCredentials")
        }
    }
}
