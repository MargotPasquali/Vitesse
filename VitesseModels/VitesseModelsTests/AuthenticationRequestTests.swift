//
//  AuthenticationRequestTests.swift
//  VitesseModelsTests
//
//  Created by Margot Pasquali on 28/09/2024.
//

import XCTest
@testable import VitesseModels

final class AuthenticationRequestTests: XCTestCase {
    
    // Test pour vérifier l'initialisation du modèle
    func testAuthenticationRequestInitialization() {
        // Given
        let email = "test@example.com"
        let password = "password123"

        // When
        let authRequest = AuthenticationRequest(email: email, password: password)

        // Then
        XCTAssertEqual(authRequest.email, email)
        XCTAssertEqual(authRequest.password, password)
    }
    
    // Test pour vérifier que l'encodage JSON fonctionne correctement
    func testAuthenticationRequestJSONEncoding() throws {
        // Given
        let authRequest = AuthenticationRequest(email: "test@example.com", password: "password123")

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(authRequest)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString, "Le résultat encodé ne doit pas être nul.")
        
        // Vérifie que le JSON contient les bons champs et valeurs
        XCTAssertTrue(jsonString!.contains("\"email\":\"test@example.com\""))
        XCTAssertTrue(jsonString!.contains("\"password\":\"password123\""))
    }
}

