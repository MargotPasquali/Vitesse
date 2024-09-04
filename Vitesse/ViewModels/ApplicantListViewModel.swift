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
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Dependencies
    
    var applicantService: ApplicantService
    var authenticationService: AuthenticationService
    
    // MARK: - Init
    
    init(authenticationService: AuthenticationService = RemoteAuthenticationService(),
         applicantService: ApplicantService = RemoteApplicantService()) {
        self.authenticationService = authenticationService
        self.applicantService = applicantService
    }
    
    // MARK: - Fetch Applicant Details
    
    func fetchApplicantDetailList() async {
        do {
            let applicantList = try await applicantService.getAllCandidates()
            Task { @MainActor in
                applicants = applicantList
            }
            print("Fetched applicants: \(self.applicants.count) candidates found")
        } catch {
            Task { @MainActor in
                print("Error fetching applicant detail list: \(error.localizedDescription)")
                applicants = []
            }
        }
    }
    
    // MARK: - Delete Applicant

    func deleteApplicant(applicant: ApplicantDetail) async {
        do {
            try await applicantService.deleteCandidate(applicant: applicant)
            Task { @MainActor in
                applicants.removeAll { $0.id == applicant.id }
            }
            print("Deleted applicant with ID: \(applicant.id)")
        } catch {
            Task { @MainActor in
                print("Error deleting applicant: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Toggle Favorite Status

    func toggleFavoriteStatus(for applicant: ApplicantDetail) async {
        do {
            // Appel à l'API pour marquer ou démarquer le candidat comme favori
            try await applicantService.putCandidateAsFavorite(applicant: applicant)
            
            // Mise à jour de l'état local
            Task { @MainActor in
                if let index = applicants.firstIndex(where: { $0.id == applicant.id }) {
                    applicants[index].isFavorite.toggle()
                }
            }
            print("Toggled favorite status for applicant with ID: \(applicant.id)")
        } catch {
            Task { @MainActor in
                print("Error toggling favorite status: \(error.localizedDescription)")
            }
        }
    }

}
