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
    
    enum RegisterViewModelError: Error {
        case registrationFailed
        case missingAccountDetails

        var localizedDescription: String {
            switch self {
            case .registrationFailed:
                return "Échec de l'enregistrement. Assurez-vous que toutes les informations fournies sont correctes. Veuillez réessayer."
            case .missingAccountDetails:
                return "Des informations sont manquantes. Assurez-vous d'avoir rempli tous les champs requis (nom, prénom, adresse e-mail et mot de passe)."
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
    
    func isFormValid() -> Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
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
    
    // MARK: - Registration Method
    
    func register() async -> Bool {
        // Vérifie si le formulaire est valide avant de procéder
        guard isFormValid() else {
            Task { @MainActor in
                errorMessage = RegisterViewModelError.missingAccountDetails.localizedDescription
            }
            return false
        }
        
        // Vérifie si les mots de passe sont identiques
        guard password == confirmPassword else {
            Task { @MainActor in
                errorMessage = "Les mots de passe ne correspondent pas. Veuillez vous assurer que le mot de passe et la confirmation du mot de passe sont identiques."
            }
            return false
        }
        
        Task { @MainActor in
            isLoading = true // Démarre le chargement
        }
        
        do {
            // Appel à l'API pour créer le compte
            try await registerService.createNewAccount(email: email, password: password, firstName: firstName, lastName: lastName)
            
            Task { @MainActor in
                errorMessage = nil // Pas d'erreur après succès
                isLoading = false // Arrête le chargement
            }
            
            return true  // Succès
        } catch let error as RegisterServiceError {
            // Gestion des erreurs spécifiques au service d'inscription
            Task { @MainActor in
                switch error {
                case .invalidCredentials:
                    errorMessage = "Les informations fournies sont invalides. Veuillez vérifier vos informations."
                case .invalidResponse:
                    errorMessage = "Réponse invalide du serveur. Veuillez réessayer plus tard."
                case .networkError:
                    // Remplacer la description détaillée de l'erreur réseau par un message générique
                    errorMessage = "Une erreur s'est produite sur le serveur. Veuillez réessayer plus tard."
                default:
                    errorMessage = "Une erreur inconnue est survenue. Veuillez réessayer."
                }
                isLoading = false
            }
            return false // Échec après une erreur spécifique
        } catch {
            // Gestion des erreurs générales
            Task { @MainActor in
                errorMessage = "Une erreur est survenue : \(error.localizedDescription)"
                isLoading = false
            }
            return false // Échec après une erreur générique
        }
    }


}
