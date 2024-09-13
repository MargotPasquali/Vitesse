//
//  ApplicantListViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation
import VitesseModels
import VitesseNetworking

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
    
}
