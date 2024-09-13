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
            filterApplicants(searchTerms: searchTerms)
        }
    }

    @Published
    var searchTerms: String = ""

    @Published var email: String = ""
    @Published var password: String = ""

    @Published
    var showFavoritesOnly = false

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

        $searchTerms
            .sink { searchTerms in
                self.filterApplicants(searchTerms: searchTerms)
            }
            .store(in: &disposables)
    }

    // MARK: - Functions

    private func filterApplicants(searchTerms: String) {
        if !searchTerms.isEmpty {
            filteredApplicants = applicants.filter { applicant in
                applicant.firstName.lowercased().contains(searchTerms.lowercased()) || applicant.lastName.lowercased().contains(searchTerms.lowercased())
            }
        } else {
            filteredApplicants = applicants
        }
    }

    // MARK: - Fetch Applicant Details
    
    func fetchApplicantDetailList() async {
        do {
            let applicantList = try await applicantService.getAllCandidates()
            
            await MainActor.run {
                print("Fetched applicants from API: \(applicantList.count) applicants") // Vérifie la quantité d'applicants récupérés
                self.applicants = applicantList
                print("Applicants stored in ViewModel: \(self.applicants.count)") // Vérifie si les données sont bien assignées
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
        // Trouver l'index du candidat dans la liste
        if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
            // Inverser la valeur de isFavorite localement
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
