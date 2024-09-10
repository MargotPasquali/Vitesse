//
//  ApplicantDetailViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 04/09/2024.
//

import Foundation
import VitesseModels
import VitesseNetworking

class ApplicantDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var applicant: ApplicantDetail
    
    // MARK: - Dependencies
    
    var applicantService: ApplicantService
    var isAdmin: Bool
    
    // MARK: - Init
    
    init(applicant: ApplicantDetail, isAdmin: Bool, applicantService: ApplicantService = RemoteApplicantService()) {
        self.applicant = applicant
        self.isAdmin = isAdmin
        self.applicantService = applicantService
    }
    
    // MARK: - Toggle Favorite
    
    func toggleFavorite() async {
        guard isAdmin else { return } // Vérifiez si l'utilisateur est admin
        do {
            try await applicantService.putCandidateAsFavorite(applicant: applicant)
            Task { @MainActor in
                self.applicant.isFavorite.toggle() // Mettre à jour l'état local
            }
            print("Toggled favorite status for applicant \(applicant.id)")
        } catch {
            print("Error toggling favorite status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Applicant Details
    
    func updateApplicantDetails() async {
        guard isAdmin else { return } // Vérifiez si l'utilisateur est admin
        do {
            try await applicantService.updateCandidateDetails(applicant: applicant)
            print("Updated applicant details for applicant \(applicant.id)")
        } catch {
            print("Error updating applicant details: \(error.localizedDescription)")
        }
    }
}
