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

    @MainActor
      func fetchApplicantDetailList() async {
          print("Fetching applicant details...")

          isLoading = true

          do {
              let applicantList = try await applicantService.getAllCandidates()

              applicants = applicantList

              isLoading = false  // Assurez-vous de remettre isLoading à false en cas de succès
          } catch let error as ApplicantServiceError {
              handleError(error)

              isLoading = false  // Remettre isLoading à false après avoir géré l'erreur
          } catch {
              let wrappedError = ApplicantServiceError.networkError(error)

              handleError(wrappedError)

              isLoading = false  // Assurez-vous que isLoading est false après une erreur générique
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
                // Ici, tu peux explicitement envelopper l'erreur dans un ApplicantServiceError.networkError si c'est un NSError
                if let nsError = error as? NSError {
                    await handleError(ApplicantServiceError.networkError(nsError))
                } else {
                    await handleError(ApplicantServiceError.unknown)
                }
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
            // Ici, si l'erreur est un NSError, on l'enveloppe dans ApplicantServiceError.networkError
            if let nsError = error as? NSError {
                await handleError(ApplicantServiceError.networkError(nsError))
            } else {
                await handleError(ApplicantServiceError.unknown)  // Transformer les erreurs génériques en .unknown
            }
        }
    }


    // MARK: - Error Handling

    @MainActor
        private func handleError(_ error: Error) {
            let errorMessage: String

            if let applicantError = error as? ApplicantServiceError {
                switch applicantError {
                case .networkError(let underlyingError):
                    // Tu peux maintenant afficher des détails supplémentaires sur l'erreur sous-jacente
                    if let nsError = underlyingError as? NSError {
                        errorMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String ?? "Erreur réseau : La réponse du serveur est invalide."
                    } else {
                        errorMessage = "Erreur réseau : La réponse du serveur est invalide."
                    }
                case .invalidResponse:
                    errorMessage = "La réponse du serveur est invalide."
                case .invalidCredentials:
                    errorMessage = "Identifiants invalides. Veuillez vérifier vos informations."
                case .unauthorized:
                    errorMessage = "Accès non autorisé. Veuillez vous authentifier."
                case .missingToken:
                    errorMessage = "Jeton manquant. Veuillez vous reconnecter."
                case .decodingError(let decodingError):
                    errorMessage = "Erreur de décodage des données : \(decodingError.localizedDescription)"
                case .unknown:
                    errorMessage = "Une erreur inconnue est survenue."
                }
            } else {
                // Pour toute autre erreur non gérée
                errorMessage = "Une erreur inconnue est survenue."
            }

            self.errorMessage = errorMessage

            print("Error: \(self.errorMessage ?? "Unknown error")")
        }
    }
