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
    
    private var applicants: [ApplicantDetail] = [] {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published
    var searchText: String = "" {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published var email: String = ""
    @Published var password: String = ""

    @Published
    var showFavoritesOnly = false {
        didSet {
            filterApplicants(searchText: searchText, showFavoritesOnly: showFavoritesOnly)
        }
    }

    @Published
    var filteredApplicants = [ApplicantDetail]()

    @Published
    var selectedApplicants = Set<UUID>()

    // MARK: - Dependencies
    
    var applicantService: ApplicantService
    var authenticationService: AuthenticationService

    private var disposables = Set<AnyCancellable>()

    // MARK: - Init
    
    init(
        authenticationService: AuthenticationService = RemoteAuthenticationService(),
         applicantService: ApplicantService = RemoteApplicantService()
    ) {
        self.authenticationService = authenticationService
        self.applicantService = applicantService

        // Met à jour les résultats quand searchText ou showFavoritesOnly changent
        $searchText
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.filterApplicants(searchText: searchText, showFavoritesOnly: self.showFavoritesOnly)
            }
            .store(in: &disposables)

        $showFavoritesOnly
            .sink { [weak self] showFavoritesOnly in
                guard let self = self else { return }
                self.filterApplicants(searchText: self.searchText, showFavoritesOnly: showFavoritesOnly)
            }
            .store(in: &disposables)
    }

    // MARK: - Functions

    private func filterApplicants(searchText: String, showFavoritesOnly: Bool) {
        // Commence avec tous les candidats
        var results = applicants

        // Filtrer par texte de recherche si nécessaire
        if !searchText.isEmpty {
            results = results.filter { applicant in
                applicant.firstName.lowercased().contains(searchText.lowercased()) ||
                applicant.lastName.lowercased().contains(searchText.lowercased())
            }
        }

        // Filtrer par favoris si nécessaire
        if showFavoritesOnly {
            results = results.filter { $0.isFavorite }
            print("Filtering to show only favorites: \(results.count) found")
        } else {
            print("Showing all applicants: \(results.count) applicants found")
        }

        // Mettre à jour les résultats filtrés
        filteredApplicants = results
    }

    // MARK: - Fetch Applicant Details
    
    func fetchApplicantDetailList() async {
        do {
            let applicantList = try await applicantService.getAllCandidates()
            
            await MainActor.run {
                print("Fetched applicants from API: \(applicantList.count) applicants")
                self.applicants = applicantList
                print("Applicants stored in ViewModel: \(self.applicants.count)")
            }
        } catch {
            await MainActor.run {
                print("Error fetching applicant detail list: \(error.localizedDescription)")
                self.applicants = []
            }
        }
    }

    // MARK: - Toggle Favorite Status
    
    func toggleFavoriteStatus(for applicant: ApplicantDetail) {
        if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
            applicants[index].isFavorite.toggle()
            print("Favorite status toggled for applicant with ID: \(applicant.id) to \(applicants[index].isFavorite)")
        }
    }
    
    // MARK: - Delete Applicant

    func deleteSelectedApplicants() async {
        let applicantsToDelete = applicants.filter { applicant in
            selectedApplicants.contains { $0 == applicant.id  }
        }

        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                applicantsToDelete.forEach { applicant in
                    taskGroup.addTask {
                        try await self.applicantService.deleteCandidate(applicant: applicant)
                    }
                }

                try await taskGroup.waitForAll()
            }

            await fetchApplicantDetailList()
        } catch {
            Task { @MainActor in
                print("Error deleting applicant: \(error.localizedDescription)")
            }
        }
    }
}
