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
    
    enum ApplicantListViewModelError: LocalizedError {
        case networkError(String)
        case dataProcessingError(String)
        case unknownError

        var errorDescription: String? {
            switch self {
            case .networkError(let message):
                return "Erreur réseau : \(message)"
            case .dataProcessingError(let message):
                return "Erreur lors du traitement des données : \(message)"
            case .unknownError:
                return "Une erreur inconnue s'est produite."
            }
        }
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
            await handleError(ApplicantListViewModelError.networkError(error.localizedDescription))
        } catch {
            await handleError(ApplicantListViewModelError.unknownError)
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
                try await applicantService.putCandidateAsFavorite(applicant: applicant)
                
                await MainActor.run {
                    self.applicants[index].isFavorite.toggle()
                }
            } catch let error as ApplicantServiceError {
                await handleError(ApplicantListViewModelError.networkError(error.localizedDescription))
            } catch {
                await handleError(ApplicantListViewModelError.unknownError)
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
            await handleError(ApplicantListViewModelError.networkError(error.localizedDescription))
        } catch {
            await handleError(ApplicantListViewModelError.unknownError)
        }
    }

    // MARK: - Error Handling

    @MainActor
    private func handleError(_ error: ApplicantListViewModelError) {
        self.errorMessage = error.localizedDescription
        self.isLoading = false
        print("Error: \(error.localizedDescription)")
    }
}
