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
            DispatchQueue.main.async {
                self.applicants = applicantList
                print("Fetched applicants: \(self.applicants.count) candidates found")
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching applicant detail list: \(error.localizedDescription)")
                self.applicants = []
            }
        }
    }
    
}
