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
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var authenticationService: AuthenticationService
    var applicantService: ApplicantService
    
    private let callback: (Bool) -> Void

    
    init(authenticationService: AuthenticationService = RemoteAuthenticationService(), applicantService: ApplicantService = RemoteApplicantService(), callback: @escaping (Bool) -> Void = { _ in }) {
        self.authenticationService = authenticationService
        self.applicantService = applicantService
        self.callback = callback
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        // Vérifie si l'email correspond au regex et n'a pas de points consécutifs
        let match = regex.firstMatch(in: email, options: [], range: range)
        
        return match != nil && !email.contains("..")
    }
    
    /// Effectue l'authentification de l'utilisateur.
    @MainActor
    func performAuthentication() async throws {
        print("Trying to authenticate with username: \(email) and password: \(password)") // Debug
        
        guard LoginViewModel.validateEmail(email), !password.isEmpty else {
            throw LoginViewModelError.authenticationFailed
        }
        
        errorMessage = nil
        
        do {
            try await authenticationService.authenticate(username: email, password: password)
        } catch {
            isLoading = false
            throw LoginViewModelError.authenticationFailed
        }
    }
    
    // MARK: - Account Details Methods
    
    /// Récupère les détails du compte de l'utilisateur après une authentification réussie.
    @MainActor
    func retrieveApplicantDetails() async throws {
        print("Retrieving account details") // Debug
        
        errorMessage = nil
        
        do {
            let applicantDetails = try await applicantService.getAllCandidates()
            print("Account details retrieved: \(applicantDetails)") // Debug
    callback(true)

        } catch {
            isLoading = false
            print("Failed to retrieve account details with error: \(error.localizedDescription)") // Debug
            throw LoginViewModelError.missingAccountDetails
        }
    }
    
    // MARK: - Login Process
    
    /// Processus de connexion complet, incluant l'authentification et la récupération des détails du compte.
    @MainActor
    func login() async throws {
        print("Starting login process") // Debug
        
        do {
            isLoading = true
            
            try await performAuthentication()
            print("Authentication step completed successfully") // Debug
            try await retrieveApplicantDetails()
            print("Account details retrieval step completed successfully") // Debug
            
            isLoading = false
        } catch {
            isLoading = false
            print("Login failed at \(error) with error: \(error.localizedDescription)") // Debug
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
}
