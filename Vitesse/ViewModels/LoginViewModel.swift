//
//  LoginViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import Foundation
class LoginViewModel: ObservableObject {
    // MARK: - Enums
    
    /// Enumération des erreurs spécifiques au `AuthenticationViewModel`.
    enum LoginViewModelError: Error {
        case authenticationFailed
        case missingAccountDetails
    }
    
    // MARK: - Published Properties
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        // Vérifie si l'email correspond au regex et n'a pas de points consécutifs
        let match = regex.firstMatch(in: email, options: [], range: range)
        
        return match != nil && !email.contains("..")
    }
}
