//
//  MockNetworkManager.swift
//  VitesseTestUtilities
//
//  Created by Margot Pasquali on 25/09/2024.
//

import Foundation
@testable import VitesseNetworking

// MARK: - MockNetworkManager

public final class MockNetworkManager: NetworkManagerProtocol {
    
    // Propriété requise par NetworkManagerProtocol
    public var token: String?
    
    // Simuler une réponse et une erreur pour les tests
    public var simulatedResponse: (Data, HTTPURLResponse)?
    public var simulatedError: Error?

    // Initialisation
    public init() {}

    // Implémentation de la méthode 'data' requise par NetworkManagerProtocol
    public func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse) {
        // Simuler une erreur si définie
        if let error = simulatedError {
            throw error
        }

        // Simuler une réponse si définie
        if let simulatedResponse = simulatedResponse {
            return simulatedResponse
        }

        // Si aucune réponse n'est définie, lancer une erreur par défaut
        throw URLError(.badServerResponse)
    }

    // Implémentation de la méthode 'set(token:)' requise par NetworkManagerProtocol
    public func set(token: String) {
        self.token = token
    }
}
