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
    
    // MARK: - Published Properties
    
    @Published var applicants: [ApplicantDetail] = [] {
        didSet {
            print("Applicants updated: \(applicants.count)")
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var searchText: String = "" {
        didSet {
            print("Search text updated: \(searchText)")
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var showFavoritesOnly = false {
        didSet {
            print("Show favorites only updated: \(showFavoritesOnly)")
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var filteredApplicants: [ApplicantDetail] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? // Pour afficher les erreurs éventuelles
    @Published var selectedApplicants: Set<UUID> = [] // Suivi des candidats sélectionnés

    // MARK: - Dependencies
    
    var applicantService: ApplicantService
    private var disposables = Set<AnyCancellable>()

    // MARK: - Init
    
    init(applicantService: ApplicantService = RemoteApplicantService()) {
        self.applicantService = applicantService
    }

    // MARK: - Fetch Applicants

    func fetchApplicantDetailList() async {
        print("Fetching applicant details...")
        
        // Exécuter sur le thread principal
        Task { @MainActor in
            self.isLoading = true
        }
        
        do {
            let applicantList = try await applicantService.getAllCandidates()
            
            // Exécuter les modifications sur le thread principal via Task @MainActor
            Task { @MainActor in
                self.applicants = applicantList
                print("Applicants stored in ViewModel: \(self.applicants.count)")
                self.isLoading = false
                self.filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
            }
        } catch {
            Task { @MainActor in
                self.applicants = []
                self.isLoading = false
                self.errorMessage = "Failed to fetch applicants: \(error.localizedDescription)"
                print("Error fetching applicants: \(error.localizedDescription)")
            }
        }
    }




    // MARK: - Filter Applicants
    
    private func filterApplicants(searchText: String, showFavoritesOnly: Bool) {
        print("Filtering applicants...")
        var results = applicants

        if !searchText.isEmpty {
            results = results.filter {
                $0.firstName.lowercased().contains(searchText.lowercased()) ||
                $0.lastName.lowercased().contains(searchText.lowercased())
            }
            print("Filtered by search text: \(searchText), \(results.count) results found")
        }

        if showFavoritesOnly {
            results = results.filter { $0.isFavorite }
            print("Filtered by favorites only: \(results.count) results found")
        }

        Task { @MainActor in
            self.filteredApplicants = results
            print("Total filtered applicants: \(self.filteredApplicants.count)")
        }
    }


    // MARK: - Toggle Favorite
    
    func toggleFavoriteStatus(for applicant: ApplicantDetail) async {
        if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
            do {
                // Appel API pour basculer le statut favori
                try await applicantService.putCandidateAsFavorite(applicant: applicant)
                
                // Mise à jour de l'état local après succès
                Task { @MainActor in
                    self.applicants[index].isFavorite.toggle()
                    print("Favorite status toggled for applicant with ID: \(applicant.id) to \(self.applicants[index].isFavorite)")
                }
            } catch {
                print("Error toggling favorite status: \(error.localizedDescription)")
            }
        }
    }


    // MARK: - Delete Selected Applicants

    func deleteSelectedApplicants() async {
        print("Deleting selected applicants...")
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

            print("Applicants deleted successfully.")
            await fetchApplicantDetailList()
        } catch {
            errorMessage = "Failed to delete applicants."
            print("Error deleting applicants: \(error.localizedDescription)")
        }
    }
}
