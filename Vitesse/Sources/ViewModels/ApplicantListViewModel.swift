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
        isLoading = true
        do {
            let applicantList = try await applicantService.getAllCandidates()
            
            // Exécuter les modifications sur le thread principal
            await MainActor.run {
                self.applicants = applicantList
                print("Applicants stored in ViewModel: \(self.applicants.count)")
                self.isLoading = false
                self.filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
            }
        } catch {
            // En cas d'erreur, il faut aussi s'assurer que l'erreur est publiée sur le main thread
            await MainActor.run {
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

        self.filteredApplicants = results
        print("Total filtered applicants: \(self.filteredApplicants.count)")
    }

    // MARK: - Toggle Favorite
    
    func toggleFavoriteStatus(for applicant: ApplicantDetail) {
        if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
            applicants[index].isFavorite.toggle()
            print("Favorite status toggled for applicant with ID: \(applicant.id) to \(applicants[index].isFavorite)")
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
