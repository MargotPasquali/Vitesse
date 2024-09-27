//
//  ApplicantDetailViewModelTests.swift
//  VitesseTests
//
//  Created by Margot Pasquali on 26/09/2024.
//

import XCTest
@testable import VitesseTestUtilities
@testable import VitesseModels
@testable import Vitesse

final class ApplicantDetailViewModelTests: XCTestCase {

    var viewModel: ApplicantDetailViewModel!
    var mockApplicantService: MockApplicantService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        
        // Instanciation du MockNetworkManager
        mockNetworkManager = MockNetworkManager()
        
        // Instanciation du MockApplicantService avec un NetworkManager
        mockApplicantService = MockApplicantService(networkManager: mockNetworkManager)
        
        // Utilisation du faux candidat défini dans FakeResponseData
        let fakeApplicant = FakeResponseData.fakeApplicant
        
        // Initialisation du ViewModel avec le faux candidat et le MockApplicantService
        viewModel = ApplicantDetailViewModel(applicant: fakeApplicant, isAdmin: true, applicantService: mockApplicantService)
    }

    override func tearDown() {
        viewModel = nil
        mockApplicantService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Test Toggle Favorite
    
    func testToggleFavorite_Success() async {
        // Given
        mockApplicantService.simulatedError = nil  // Aucune erreur simulée
        XCTAssertFalse(viewModel.applicant.isFavorite, "Le candidat ne devrait pas être favori au départ.")

        // When
        await viewModel.toggleFavorite()

        // Attendre la mise à jour asynchrone
        await Task.yield()  // Forcer la mise à jour complète de l'état

        // Then
        print("Valeur isFavorite après toggle: \(viewModel.applicant.isFavorite)")
        XCTAssertTrue(viewModel.applicant.isFavorite, "Le candidat devrait être favori après basculement.")
    }

    func testToggleFavorite_Failure() async {
        // Given
        mockApplicantService.simulatedError = .networkError(NSError(domain: "TestErrorDomain", code: 500, userInfo: nil))
        XCTAssertFalse(viewModel.applicant.isFavorite, "Le candidat ne devrait pas être favori au départ.")
        
        // When
        await viewModel.toggleFavorite()
        
        // Then
        XCTAssertFalse(viewModel.applicant.isFavorite, "Le candidat ne devrait pas changer de statut en cas d'erreur réseau.")
    }
    
    // MARK: - Test Update Applicant Details
    
    func testUpdateApplicantDetails_Success() async {
        // Given
        mockApplicantService.simulatedError = nil  // Aucune erreur simulée
        viewModel.applicant.note = "Updated note"
        
        // When
        await viewModel.updateApplicantDetails()
        
        // Then
        XCTAssertEqual(mockApplicantService.updatedApplicant?.note, "Updated note", "Les détails du candidat devraient être mis à jour avec succès.")
    }
    
    func testUpdateApplicantDetails_Failure() async {
        // Given
        mockApplicantService.simulatedError = .networkError(NSError(domain: "TestErrorDomain", code: 500, userInfo: nil))
        viewModel.applicant.note = "Failed update note"
        
        // When
        await viewModel.updateApplicantDetails()
        
        // Then
        XCTAssertNotEqual(mockApplicantService.updatedApplicant?.note, "Failed update note", "Les détails du candidat ne devraient pas être mis à jour en cas d'erreur.")
    }

    func testUpdateApplicantDetails_NotAdmin() async {
        // Given
        viewModel.isAdmin = false  // L'utilisateur n'est pas admin
        viewModel.applicant.note = "Updated note"
        
        // When
        await viewModel.updateApplicantDetails()
        
        // Then
        XCTAssertNil(mockApplicantService.updatedApplicant, "Les détails du candidat ne devraient pas être mis à jour si l'utilisateur n'est pas admin.")
    }
}
