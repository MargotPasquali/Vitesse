//
//  ApplicantListViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

class ApplicantListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var applicants: [ApplicantDetail] = []
    
    @Published var email: String = ""  // Utilisé pour l'authentification
    @Published var password: String = ""  // Utilisé pour l'authentification

    // MARK: - Dependencies
    var applicantService: ApplicantService
    var authenticationService: AuthenticationService
    
    // MARK: - Init
    init(authenticationService: AuthenticationService = RemoteAuthenticationService(),
         applicantService: ApplicantService = RemoteApplicantService()) {
        self.authenticationService = authenticationService
        self.applicantService = applicantService
    }
    
    // MARK: - Authenticate and Fetch Applicants
    func authenticateAndFetchApplicants() {
        Task {
            do {
                // Vérification des informations d'identification
                print("Attempting to authenticate with email: \(email) and password: \(password)")
                
                guard !email.isEmpty else {
                    print("Error: Email is empty")
                    throw ApplicantServiceError.invalidCredentials
                }
                guard !password.isEmpty else {
                    print("Error: Password is empty")
                    throw ApplicantServiceError.invalidCredentials
                }
                
                // Authentification de l'utilisateur
                try await authenticationService.authenticate(username: email, password: password)
                print("Authentication successful")
                
                // Ensuite, on peut appeler getCandidate
                let applicants = try await applicantService.getCandidate()
                print("Fetched applicants: \(applicants.count) candidates found")
                
                DispatchQueue.main.async {
                    self.applicants = applicants
                    print("Applicants updated in ViewModel")
                }
            } catch {
                print("Error during login or fetching candidates: \(error)")
            }
        }
    }
}
