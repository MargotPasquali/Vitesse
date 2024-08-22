//
//  RegisterViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//
import Foundation

class RegisterViewModel: ObservableObject {
    
    // MARK: - Enums
    enum RegisterViewModelError: Error {
        case authenticationFailed
        case missingAccountDetails
    }
    
    // MARK: - Published Properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    
    var registerService: RegisterService
    
    init(registerService: RegisterService = RemoteRegisterService()) {
        self.registerService = registerService
    }
    
    // Method to handle registration
    @MainActor
    func register() async -> Bool {
        // Vérification si l'email est valide
        guard isValidEmail(email) else {
            errorMessage = "Please provide a valid email address."
            return false
        }
        
        // Vérification si le formulaire est valide
        guard isFormValid() else {
            errorMessage = "Please fill in all fields correctly."
            return false
        }
        
        do {
            // Appel à l'API pour créer un nouveau compte
            try await registerService.createNewAccount(email: email, password: password, firstName: firstName, lastName: lastName)
            return true // Succès de la création du compte
        } catch let error as RegisterServiceError {
            switch error {
            case .invalidCredentials:
                errorMessage = "Please provide valid credentials."
            case .unauthorized:
                errorMessage = "Unauthorized access. Please check your credentials."
            case .serverError:
                errorMessage = "Server error. Please try again later."
            case .networkError(let netError):
                errorMessage = "Network error: \(netError.localizedDescription)"
            case .decodingError(let decodingError):
                errorMessage = "Failed to decode response: \(decodingError.localizedDescription)"
            default:
                errorMessage = "An unknown error occurred."
            }
            return false
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Private Methods
    
    func isFormValid() -> Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        let match = regex.firstMatch(in: email, options: [], range: range)
        return match != nil && !email.contains("..")
    }
}
