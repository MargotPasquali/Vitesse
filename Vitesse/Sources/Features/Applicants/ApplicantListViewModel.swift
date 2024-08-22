//
// Copyright (C) 2024 Vitesse
//

import Foundation
import VitesseModels
import VitesseNetworking

// MARK: - ApplicantListViewModel

/// ViewModel responsable de la gestion des détails du compte.
///
/// Cette classe gère la récupération et la mise à jour des informations de compte, telles que le solde total et les transactions récentes.
class ApplicantListViewModel: ObservableObject {
    
    // MARK: - Published Properties

    @Published var phone: String = ""
    @Published var note: String = ""
    @Published var id : String = ""
    @Published var firstName: String = ""
    @Published var linkedinURL: String = ""
    @Published var email: String = ""
    @Published var lastName: String = ""
    
    @Published var applicants: [ApplicantDetail] = []

    
    // MARK: - Dependencies
    
    var applicantService: ApplicantService
    
    // MARK: - Init
    
    /// Initialise le ViewModel avec un service de compte.
    ///
    /// Récupère immédiatement les détails du compte lors de l'initialisation.
    init(applicantService: ApplicantService = RemoteApplicantService()) {
        self.applicantService = applicantService
        Task {
            await fetchApplicantDetailList()
        }
    }
    
    // MARK: - Fetch Account Details
    
    /// Récupère les détails du compte et met à jour les propriétés publiées.
    ///
    /// Cette méthode est exécutée de manière asynchrone pour appeler le service de compte.
    func fetchApplicantDetailList() async {
        do {
            let applicantList = try await applicantService.getCandidate()
            DispatchQueue.main.async {
                self.applicants = applicantList
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching account details: \(error.localizedDescription)")
                self.applicants = []
                
            }
        }
    }
}

