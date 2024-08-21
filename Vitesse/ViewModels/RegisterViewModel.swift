//
//  RegisterViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import Foundation

class RegisterViewModel: ObservableObject {
    // MARK: - Enums
    
    /// Enumération des erreurs spécifiques au `RegisterViewModel`.
    enum registerViewModelError: Error {
        case authenticationFailed
        case missingAccountDetails
    }
    
    // MARK: - Published Properties
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var errorMessage: String?
    
    // Method to check if the form is valid
    func isFormValid() -> Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    // Simple email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        // Vérifie si l'email correspond au regex et n'a pas de points consécutifs
        let match = regex.firstMatch(in: email, options: [], range: range)
        
        return match != nil && !email.contains("..")
    }
    
    // Method to handle registration
    func register() -> Bool {
        // Logic to create a user account, e.g., calling an API or saving to a database.
        // Return true if successful, otherwise false.
        
        // For the sake of example, let's assume the registration always succeeds.
        // Replace this with actual logic.
        let registrationSuccessful = true
        
        if registrationSuccessful {
            return true
        } else {
            errorMessage = "An error occurred during account creation."
            return false
        }
    }
    
}
