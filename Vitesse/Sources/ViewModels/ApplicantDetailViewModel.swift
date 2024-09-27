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
        do {
            // Appel API pour basculer le statut favori
            try await applicantService.putCandidateAsFavorite(applicant: applicant)

            // Utilisation de MainActor pour garantir que la mise à jour est exécutée sur le thread principal
            await MainActor.run {
                self.applicant.isFavorite.toggle()  // Basculer le statut dans le ViewModel
                print("isFavorite dans le ViewModel a changé pour \(self.applicant.isFavorite)")
            }
            print("Successfully toggled favorite status for applicant \(applicant.id)")
        } catch {
            print("Error toggling favorite status: \(error.localizedDescription)")
        }
    }



    @MainActor
    func updateApplicantDetails() async {
        guard isAdmin else { return } // Vérifiez si l'utilisateur est admin

        do {
            // Créer une copie du candidat sans `isFavorite`
            var updatedApplicant = applicant
            // Supprimer `isFavorite` en tant que champ envoyé dans la requête
            // Ici, on doit exclure explicitement isFavorite de l'update
            // En modifiant le modèle que tu envoies dans la requête PUT
            // On ne change pas la valeur de `isFavorite` dans `updatedApplicant`, mais on ne l'inclut pas dans l'envoi

            // Appel API pour mettre à jour les détails du candidat, sans changer le statut favori
            try await applicantService.updateCandidateDetails(applicant: updatedApplicant)

            print("Updated applicant details for applicant \(updatedApplicant.id)")
        } catch {
            print("Error updating applicant details: \(error.localizedDescription)")
        }
    }


}
