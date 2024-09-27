//
//  ApplicantListViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation
import VitesseModels
import VitesseNetworking
import Combine

class ApplicantListViewModel: ObservableObject {
    
    public enum ApplicantServiceError: Error {
        case invalidCredentials
        case invalidResponse
        case unauthorized
        case missingToken
        case serverError(Int, message: String)  // Inclure le code de statut et le message
        case networkError(Error)
        case decodingError(DecodingError)
        case unknown
    }



    // MARK: - Published Properties
    
    @Published var applicants: [ApplicantDetail] = [] {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var searchText: String = "" {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var showFavoritesOnly = false {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var filteredApplicants: [ApplicantDetail] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? // Pour afficher les erreurs éventuelles
    @Published var selectedApplicants: Set<UUID> = [] // Suivi des candidats sélectionnés

    // MARK: - Dependencies
    
    var applicantService: ApplicantService

    // MARK: - Init
    
    init(applicantService: ApplicantService = RemoteApplicantService()) {
        self.applicantService = applicantService
    }

    // MARK: - Fetch Applicants

    func fetchApplicantDetailList() async {
        print("Fetching applicant details...")

        self.isLoading = true
        
        do {
            let applicantList = try await applicantService.getAllCandidates()
            await MainActor.run {
                self.applicants = applicantList
                self.isLoading = false
                self.filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
            }
        } catch let error as ApplicantServiceError {
            await handleError(error) // Gérer ApplicantServiceError correctement
        } catch {
            // Si l'erreur ne correspond pas à ApplicantServiceError, la convertir explicitement en .networkError
            let wrappedError = ApplicantServiceError.networkError(error)
            await handleError(wrappedError)
        }
    }


    // MARK: - Filter Applicants
    
    private func filterApplicants(searchText: String, showFavoritesOnly: Bool) {
        var results = applicants

        if !searchText.isEmpty {
            results = results.filter {
                $0.firstName.lowercased().contains(searchText.lowercased()) ||
                $0.lastName.lowercased().contains(searchText.lowercased())
            }
        }

        if showFavoritesOnly {
            results = results.filter { $0.isFavorite }
        }

        Task { @MainActor in
            self.filteredApplicants = results
        }
    }

    // MARK: - Toggle Favorite
    
    func toggleFavoriteStatus(for applicant: ApplicantDetail) async {
        if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
            do {
                // Cet appel peut lever une erreur serveur
                try await applicantService.putCandidateAsFavorite(applicant: applicant)
                
                await MainActor.run {
                    self.applicants[index].isFavorite.toggle()
                }
            } catch let error as ApplicantServiceError {
                // Capture des erreurs spécifiques de ApplicantServiceError
                await handleError(error)
            } catch {
                // Conversion des erreurs génériques en ApplicantServiceError.unknown
                await handleError(ApplicantServiceError.unknown)
            }
        }
    }




    // MARK: - Delete Selected Applicants
    
    func deleteSelectedApplicants() async {
        let applicantsToDelete = applicants.filter { selectedApplicants.contains($0.id) }

        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                for applicant in applicantsToDelete {
                    taskGroup.addTask {
                        try await self.applicantService.deleteCandidate(applicant: applicant)
                    }
                }
                try await taskGroup.waitForAll()
            }

            await fetchApplicantDetailList()
        } catch let error as ApplicantServiceError {
            print("Error captured: \(error)")
            await handleError(error)  // Gérer les erreurs spécifiques à ApplicantServiceError
        } catch {
            print("Unknown error captured: \(error)")
            await handleError(ApplicantServiceError.unknown)  // Transformer les erreurs génériques en .unknown
        }
    }

    // MARK: - Error Handling

    @MainActor
    private func handleError(_ error: Error) {
        if let applicantError = error as? ApplicantServiceError {
            switch applicantError {
            case .networkError(let networkError as NSError):
                self.errorMessage = "Erreur réseau : \(networkError.localizedDescription)"
            case .invalidResponse:
                self.errorMessage = "La réponse du serveur est invalide."
            case .serverError(_, let message):  // Afficher le message d'erreur personnalisé
                self.errorMessage = message
            case .invalidCredentials:
                self.errorMessage = "Identifiants invalides. Veuillez vérifier vos informations."
            case .unauthorized:
                self.errorMessage = "Accès non autorisé. Veuillez vous authentifier."
            case .missingToken:
                self.errorMessage = "Jeton manquant. Veuillez vous reconnecter."
            case .decodingError(let decodingError):
                self.errorMessage = "Erreur de décodage des données : \(decodingError.localizedDescription)"
            case .unknown:
                self.errorMessage = "Une erreur inconnue est survenue."
            }
        } else {
            // Pour toute autre erreur non gérée
            self.errorMessage = "Une erreur inconnue est survenue."
        }
        self.isLoading = false
        print("Error: \(self.errorMessage ?? "Unknown error")")
    }



}
