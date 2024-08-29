//
//  ApplicantListViewModel.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

final class ApplicantListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var applicants: [ApplicantDetail] = []
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Dependencies

    private let applicantService: ApplicantService
    private let authenticationService: AuthenticationService

    // MARK: - Init

    init(
        authenticationService: AuthenticationService = RemoteAuthenticationService(),
        applicantService: ApplicantService = RemoteApplicantService()
    ) {
        self.authenticationService = authenticationService
        self.applicantService = applicantService
    }

    // MARK: - Fetch Applicant Details
    
    func fetchApplicantDetailList() async {
        do {
            let newApplicants = try await applicantService.getAllCandidates()

            Task { @MainActor in
                applicants = newApplicants
            }

            print("Fetched applicants: \(applicants.count) candidates found")
        } catch {
            print("Error fetching applicant detail list: \(error.localizedDescription)")

            Task { @MainActor in
                applicants = []
            }
        }
    }
}
