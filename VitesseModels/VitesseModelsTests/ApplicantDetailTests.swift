//
//  ApplicantDetailTests.swift
//  VitesseModelsTests
//
//  Created by Margot Pasquali on 28/09/2024.
//

import XCTest
@testable import VitesseModels

final class ApplicantDetailTests: XCTestCase {
    
    // Test d'initialisation du modèle
    func testApplicantDetailInitialization() {
        // Given
        let id = UUID()
        let firstName = "John"
        let lastName = "Doe"
        let email = "john.doe@example.com"
        let phone = "1234567890"
        let linkedinURL = "https://linkedin.com/in/johndoe"
        let note = "This is a note"
        let isFavorite = true
        
        // When
        let applicant = ApplicantDetail(id: id, firstName: firstName, lastName: lastName, email: email, phone: phone, linkedinURL: linkedinURL, note: note, isFavorite: isFavorite)
        
        // Then
        XCTAssertEqual(applicant.id, id)
        XCTAssertEqual(applicant.firstName, firstName)
        XCTAssertEqual(applicant.lastName, lastName)
        XCTAssertEqual(applicant.email, email)
        XCTAssertEqual(applicant.phone, phone)
        XCTAssertEqual(applicant.linkedinURL, linkedinURL)
        XCTAssertEqual(applicant.note, note)
        XCTAssertEqual(applicant.isFavorite, isFavorite)
    }
    
    // Test d'encodage en JSON
    func testApplicantDetailJSONEncoding() throws {
        // Given
        let applicant = ApplicantDetail(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "1234567890",
            linkedinURL: "https://linkedin.com/in/johndoe",
            note: "This is a note",
            isFavorite: true
        )

        // When
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Juste pour mieux visualiser le JSON généré
        let jsonData = try encoder.encode(applicant)
        
        // Pour diagnostiquer le JSON généré
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("JSON généré : \(jsonString!)")
        
        // Then - Re-décoder le JSON généré et vérifier les propriétés
        let decoder = JSONDecoder()
        let decodedApplicant = try decoder.decode(ApplicantDetail.self, from: jsonData)

        // Vérifier que les propriétés sont bien celles attendues
        XCTAssertEqual(decodedApplicant.firstName, "John")
        XCTAssertEqual(decodedApplicant.lastName, "Doe")
        XCTAssertEqual(decodedApplicant.email, "john.doe@example.com")
        XCTAssertEqual(decodedApplicant.phone, "1234567890")
        XCTAssertEqual(decodedApplicant.linkedinURL, "https://linkedin.com/in/johndoe")
        XCTAssertEqual(decodedApplicant.note, "This is a note")
        XCTAssertTrue(decodedApplicant.isFavorite)
    }

    // Test de décodage à partir d'un JSON
    func testApplicantDetailJSONDecoding() throws {
        // Given
        let json = """
        {
            "id": "533226E7-3C92-4499-8430-21386B0F2DFF",
            "firstName": "John",
            "lastName": "Doe",
            "email": "john.doe@example.com",
            "phone": "1234567890",
            "linkedinURL": "https://linkedin.com/in/johndoe",
            "note": "This is a note",
            "isFavorite": true
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let applicant = try decoder.decode(ApplicantDetail.self, from: json)
        
        // Then
        XCTAssertEqual(applicant.firstName, "John")
        XCTAssertEqual(applicant.lastName, "Doe")
        XCTAssertEqual(applicant.email, "john.doe@example.com")
        XCTAssertEqual(applicant.phone, "1234567890")
        XCTAssertEqual(applicant.linkedinURL, "https://linkedin.com/in/johndoe")
        XCTAssertEqual(applicant.note, "This is a note")
        XCTAssertTrue(applicant.isFavorite)
    }
    
    // Test de conformité à Equatable
    func testApplicantDetailEquatable() {
        // Given
        let applicant1 = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: "https://linkedin.com/in/johndoe", note: "This is a note", isFavorite: true)
        let applicant2 = ApplicantDetail(id: applicant1.id, firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: "https://linkedin.com/in/johndoe", note: "This is a note", isFavorite: true)

        // When/Then
        XCTAssertEqual(applicant1, applicant2, "Deux objets ApplicantDetail avec les mêmes propriétés devraient être égaux.")
    }
    
    // Test pour vérifier que isFavorite change correctement
    func testApplicantDetailIsFavoriteToggle() {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)

        // When
        applicant.isFavorite = true
        
        // Then
        XCTAssertTrue(applicant.isFavorite, "isFavorite devrait être true après le basculement.")
    }
}
