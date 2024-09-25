//
//  RegisterViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import Foundation
import VitesseNetworking

class RegisterViewModel: ObservableObject {
    
    // MARK: - Enums
    
    /// Enumération des erreurs spécifiques au `RegisterViewModel`.
    enum RegisterViewModelError: Error {
        case registrationFailed
        case missingAccountDetails
        case passwordNotIdentical

        var localizedDescription: String {
            switch self {
            case .registrationFailed:
                return "Échec de l'enregistrement. Assurez-vous que toutes les informations fournies sont correctes. Veuillez réessayer."
            case .missingAccountDetails:
                return "Des informations sont manquantes. Assurez-vous d'avoir rempli tous les champs requis (nom, prénom, adresse e-mail et mot de passe)."
            case .passwordNotIdentical:
                return "Les mots de passe ne correspondent pas. Veuillez vous assurer que le mot de passe et la confirmation du mot de passe sont identiques."
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var registerService: RegisterService
    
    // MARK: - Init
    init(registerService: RegisterService = RemoteRegisterService()) {
        self.registerService = registerService
    }
    
    // MARK: - Validation Methods
    
    /// Vérifie si le formulaire est valide
    func isFormValid() -> Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    /// Vérifie si l'adresse email est valide
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        let match = regex.firstMatch(in: email, options: [], range: range)
        return match != nil && !email.contains("..")
    }
    
    // MARK: - Registration Method
    
    /// Gère l'inscription et appelle l'API
    func register() async -> Bool {
        // Validation des champs
        guard isFormValid() else {
            Task { @MainActor in
                errorMessage = RegisterViewModelError.missingAccountDetails.localizedDescription
            }
            return false
        }
        
        // Vérifie si les mots de passe sont identiques
        guard password == confirmPassword else {
            Task { @MainActor in
                errorMessage = RegisterViewModelError.passwordNotIdentical.localizedDescription
            }
            return false
        }
        
        do {
            // Indique que l'inscription est en cours
            isLoading = true

            // Appel à l'API pour créer le compte
            try await registerService.createNewAccount(email: email, password: password, firstName: firstName, lastName: lastName)
            
            Task { @MainActor in
                // Réinitialisation des erreurs après succès
                errorMessage = nil
                isLoading = false
            }
            
            return true  // Succès
        } catch let error as RegisterServiceError {
            // Gestion des erreurs liées au service d'inscription
            Task { @MainActor in
                switch error {
                case .invalidCredentials:
                    errorMessage = "Les identifiants fournis ne sont pas valides. Veuillez vérifier vos informations."
                case .invalidResponse:
                    errorMessage = "La réponse du serveur est invalide. Veuillez réessayer plus tard."
                case .networkError(let networkError):
                    errorMessage = "Une erreur s'est produite sur le serveur. Veuillez réessayer plus tard."
                default:
                    errorMessage = "Une erreur inconnue s'est produite. Veuillez réessayer."
                }
                isLoading = false
            }
        } catch {
            // Gestion des erreurs génériques
            Task { @MainActor in
                errorMessage = "Une erreur est survenue : \(error.localizedDescription)"
                isLoading = false
            }
        }
        return false  // Échec
    }
}
