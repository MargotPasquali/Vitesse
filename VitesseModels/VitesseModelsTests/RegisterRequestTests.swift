//
//  RegisterRequestTests.swift
//  VitesseModelsTests
//
//  Created by Margot Pasquali on 28/09/2024.
//

import XCTest
@testable import VitesseModels

final class RegisterRequestTests: XCTestCase {

    // Test d'initialisation du modèle
    func testRegisterRequestInitialization() {
        // Given
        let email = "john.doe@example.com"
        let password = "securePassword123"
        let firstName = "John"
        let lastName = "Doe"
        
        // When
        let request = RegisterRequest(email: email, password: password, firstName: firstName, lastName: lastName)
        
        // Then
        XCTAssertEqual(request.email, email)
        XCTAssertEqual(request.password, password)
        XCTAssertEqual(request.firstName, firstName)
        XCTAssertEqual(request.lastName, lastName)
    }

    // Test d'encodage en JSON avec toutes les propriétés définies
    func testRegisterRequestJSONEncoding() throws {
        // Given
        let request = RegisterRequest(
            email: "john.doe@example.com",
            password: "securePassword123",
            firstName: "John",
            lastName: "Doe"
        )

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString, "L'encodage JSON ne devrait pas retourner nil.")
        XCTAssertTrue(jsonString!.contains("\"email\":\"john.doe@example.com\""))
        XCTAssertTrue(jsonString!.contains("\"password\":\"securePassword123\""))
        XCTAssertTrue(jsonString!.contains("\"firstName\":\"John\""))
        XCTAssertTrue(jsonString!.contains("\"lastName\":\"Doe\""))
    }

    // Test d'encodage JSON avec des caractères spéciaux
    func testRegisterRequestJSONEncoding_WithSpecialCharacters() throws {
        // Given
        let request = RegisterRequest(
            email: "test@example.com",
            password: "P@ssw0rd!",
            firstName: "Élise",
            lastName: "L'Écuyer"
        )

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)

        // Then
        XCTAssertNotNil(jsonString, "L'encodage JSON ne devrait pas retourner nil.")
        XCTAssertTrue(jsonString!.contains("\"email\":\"test@example.com\""))
        XCTAssertTrue(jsonString!.contains("\"password\":\"P@ssw0rd!\""))
        XCTAssertTrue(jsonString!.contains("\"firstName\":\"Élise\""))
        XCTAssertTrue(jsonString!.contains("\"lastName\":\"L'Écuyer\""))
    }
}
