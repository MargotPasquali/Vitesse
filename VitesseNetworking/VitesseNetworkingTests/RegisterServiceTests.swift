//
//  RegisterServiceTests.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 26/09/2024.
//

import XCTest
@testable import VitesseNetworking
import Vitesse
import VitesseModels
import VitesseTestUtilities

final class RegisterServiceTests: XCTestCase {

    var registerService: RegisterService!
    var mockNetworkManager: MockNetworkManager!  // Plus d'optionnel ici, il sera initialisé correctement

    override func setUp() {
        super.setUp()

        // Initialisation correcte du MockNetworkManager
        mockNetworkManager = MockNetworkManager()

        // Initialisation directe de RegisterService avec mockNetworkManager
        registerService = RemoteRegisterService(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        registerService = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    // MARK: - Test d'une inscription réussie
    func testCreateNewAccount_Success() async throws {
        // Given
        let jsonData = """
        {
            "message": "Account created successfully"
        }
        """.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080")!, statusCode: 201, httpVersion: nil, headerFields: nil)!

        // Simuler une réponse réussie du serveur
        mockNetworkManager.simulatedResponse = (jsonData, response)

        // When / Then
        do {
            try await registerService.createNewAccount(email: "john.doe@example.com", password: "password123", firstName: "John", lastName: "Doe")
        } catch {
            XCTFail("La création de compte devrait réussir, mais une erreur a été lancée : \(error)")
        }
    }

    // MARK: - Test d'une erreur réseau
    func testCreateNewAccount_NetworkError() async throws {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        mockNetworkManager.simulatedError = networkError

        // When / Then
        do {
            try await registerService.createNewAccount(email: "john.doe@example.com", password: "password123", firstName: "John", lastName: "Doe")
            XCTFail("La création de compte devrait échouer en cas d'erreur réseau.")
        } catch RegisterServiceError.networkError(let error as URLError) {
            XCTAssertEqual(error.code, .notConnectedToInternet, "L'erreur réseau devrait correspondre à .notConnectedToInternet")
        } catch {
            XCTFail("L'erreur retournée devrait être .networkError")
        }
    }

    // Autres tests ici...
}
