//
//  AuthenticationResponseTests.swift
//  VitesseModelsTests
//
//  Created by Margot Pasquali on 28/09/2024.
//

import XCTest
@testable import VitesseModels

final class AuthenticationResponseTests: XCTestCase {
    
    // Test d'initialisation du modèle
    func testAuthenticationResponseInitialization() {
        // Given
        let token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        let isAdmin = true
        
        // When
        let response = AuthenticationResponse(token: token, isAdmin: isAdmin)
        
        // Then
        XCTAssertEqual(response.token, token)
        XCTAssertEqual(response.isAdmin, isAdmin)
    }
    
    // Test d'encodage en JSON
    func testAuthenticationResponseJSONEncoding() throws {
        // Given
        let response = AuthenticationResponse(token: "FB24D136-C228-491D-AB30-FDFD97009D19", isAdmin: true)

        // When
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(response)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString, "L'encodage JSON ne devrait pas retourner nil.")
        XCTAssertTrue(jsonString!.contains("\"token\":\"FB24D136-C228-491D-AB30-FDFD97009D19\""))
        XCTAssertTrue(jsonString!.contains("\"isAdmin\":true"))
    }

    // Test de décodage à partir de JSON
    func testAuthenticationResponseJSONDecoding() throws {
        // Given
        let json = """
        {
            "token": "FB24D136-C228-491D-AB30-FDFD97009D19",
            "isAdmin": true
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response = try decoder.decode(AuthenticationResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
        XCTAssertTrue(response.isAdmin)
    }
    
    // Test de décodage à partir de JSON avec isAdmin false
    func testAuthenticationResponseJSONDecoding_WithFalseAdmin() throws {
        // Given
        let json = """
        {
            "token": "FB24D136-C228-491D-AB30-FDFD97009D19",
            "isAdmin": false
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response = try decoder.decode(AuthenticationResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
        XCTAssertFalse(response.isAdmin)
    }
}

