//
//  ApplicationCreationRequestTests.swift
//  VitesseModelsTests
//
//  Created by Margot Pasquali on 28/09/2024.
//

import XCTest
@testable import VitesseModels

final class ApplicantCreationRequestTests: XCTestCase {

    // Test de l'initialisation du modèle
    func testApplicantCreationRequestInitialization() {
        // Given
        let email = "john.doe@example.com"
        let note = "This is a note"
        let linkedinURL = "https://linkedin.com/in/johndoe"
        let firstName = "John"
        let lastName = "Doe"
        let phone = "1234567890"
        
        // When
        let request = ApplicantCreationRequest(email: email, note: note, linkedinURL: linkedinURL, firstName: firstName, lastName: lastName, phone: phone)
        
        // Then
        XCTAssertEqual(request.email, email)
        XCTAssertEqual(request.note, note)
        XCTAssertEqual(request.linkedinURL, linkedinURL)
        XCTAssertEqual(request.firstName, firstName)
        XCTAssertEqual(request.lastName, lastName)
        XCTAssertEqual(request.phone, phone)
    }

    // Test d'encodage JSON avec toutes les propriétés définies
    func testApplicantCreationRequestJSONEncoding_WithAllProperties() throws {
        // Given
        let request = ApplicantCreationRequest(
            email: "john.doe@example.com",
            note: "This is a note",
            linkedinURL: "https://linkedin.com/in/johndoe",
            firstName: "John",
            lastName: "Doe",
            phone: "1234567890"
        )

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString, "L'encodage JSON ne devrait pas retourner nil.")
        
        // Vérification plus flexible pour l'URL LinkedIn, sans se soucier des caractères échappés
        XCTAssertTrue(jsonString!.contains("\"linkedinURL\":\"https://linkedin.com/in/johndoe\"") ||
                      jsonString!.contains("\"linkedinURL\":\"https:\\/\\/linkedin.com\\/in\\/johndoe\""),
                      "Le JSON devrait contenir l'URL LinkedIn correcte, même avec les caractères échappés.")
        
        XCTAssertTrue(jsonString!.contains("\"email\":\"john.doe@example.com\""))
        XCTAssertTrue(jsonString!.contains("\"note\":\"This is a note\""))
        XCTAssertTrue(jsonString!.contains("\"firstName\":\"John\""))
        XCTAssertTrue(jsonString!.contains("\"lastName\":\"Doe\""))
        XCTAssertTrue(jsonString!.contains("\"phone\":\"1234567890\""))
    }

    // Test d'encodage JSON avec des propriétés optionnelles nil
    func testApplicantCreationRequestJSONEncoding_WithNilOptionalProperties() throws {
        // Given
        let request = ApplicantCreationRequest(
            email: "jane.doe@example.com",
            note: nil,               // Note optionnelle est nil
            linkedinURL: nil,         // LinkedIn URL est nil
            firstName: "Jane",
            lastName: "Doe",
            phone: "0987654321"
        )

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString, "L'encodage JSON ne devrait pas retourner nil.")
        XCTAssertTrue(jsonString!.contains("\"email\":\"jane.doe@example.com\""))
        XCTAssertTrue(jsonString!.contains("\"firstName\":\"Jane\""))
        XCTAssertTrue(jsonString!.contains("\"lastName\":\"Doe\""))
        XCTAssertTrue(jsonString!.contains("\"phone\":\"0987654321\""))
        XCTAssertFalse(jsonString!.contains("note"), "La propriété 'note' ne devrait pas être présente dans le JSON quand elle est nil.")
        XCTAssertFalse(jsonString!.contains("linkedinURL"), "La propriété 'linkedinURL' ne devrait pas être présente dans le JSON quand elle est nil.")
    }
}
