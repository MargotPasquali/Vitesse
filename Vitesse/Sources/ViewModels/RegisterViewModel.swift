//
//  RegisterViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import Foundation
import VitesseNetworking

class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?

    private var registerService: RegisterService
    
    // MARK: - Init
    init(registerService: RegisterService = RemoteRegisterService()) {
        self.registerService = registerService
    }
    
    // Method to check if the form is valid
    func isFormValid() -> Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    // Method to handle registration (calls the API)
    func register() async -> Bool {
        do {
            // Appel à l'API pour créer le compte
            try await registerService.createNewAccount(email: email, password: password, firstName: firstName, lastName: lastName)
            
            Task { @MainActor in
                // Mise à jour de l'interface utilisateur après succès
                errorMessage = nil // Pas d'erreur
            }
            
            return true  // Succès
        } catch {
            Task { @MainActor in
                // Gestion des erreurs spécifiques sur le thread principal
                if let registerError = error as? RegisterServiceError {
                    switch registerError {
                    case .invalidCredentials:
                        errorMessage = "Invalid credentials. Please check your details."
                    case .invalidResponse:
                        errorMessage = "Invalid response from server."
                    case .networkError(let networkError):
                        errorMessage = "Network error: \(networkError.localizedDescription)"
                    default:
                        errorMessage = "An unknown error occurred."
                    }
                } else {
                    errorMessage = "An error occurred: \(error.localizedDescription)"
                }
            }
            return false  // Échec
        }
    }

    
    // Simple email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        let match = regex.firstMatch(in: email, options: [], range: range)
        return match != nil && !email.contains("..")
    }
}
