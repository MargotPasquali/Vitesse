////
////  ApplicantListViewModelTests.swift
////  VitesseTests
////
////  Created by Margot Pasquali on 25/09/2024.


import XCTest
import Combine
@testable import VitesseTestUtilities
@testable import VitesseModels
@testable import Vitesse

final class ApplicantListViewModelTests: XCTestCase {

    var viewModel: ApplicantListViewModel!
    var mockApplicantService: MockApplicantService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()

        // Création des mocks
        mockNetworkManager = MockNetworkManager()
        mockApplicantService = MockApplicantService(networkManager: mockNetworkManager)

        // Initialisation du ViewModel avec le service de candidats mocké
        viewModel = ApplicantListViewModel(applicantService: mockApplicantService)
    }

    override func tearDown() {
        viewModel = nil
        mockApplicantService = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    // MARK: - Tests de récupération des candidats

    func testFetchApplicantDetailList_Success() async throws {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        mockApplicantService.applicantList = [applicant]

        // When
        await viewModel.fetchApplicantDetailList()

        // Then
        XCTAssertEqual(viewModel.applicants.count, 1, "Le ViewModel devrait avoir 1 candidat après un succès.")
        XCTAssertEqual(viewModel.applicants.first?.firstName, "John", "Le nom du candidat devrait être 'John'.")
        XCTAssertFalse(viewModel.isLoading, "isLoading devrait être false après la récupération des candidats.")
        XCTAssertNil(viewModel.errorMessage, "Le message d'erreur devrait être nul après un succès.")
    }

    func testFetchApplicantDetailList_Failure_NetworkError() async throws {
        // Given
        // Simule uniquement l'erreur dans MockApplicantService
        let networkError = NSError(domain: "NetworkError", code: FakeResponseData.responseKo.statusCode, userInfo: [NSLocalizedDescriptionKey: "La réponse du serveur est invalide."])
        mockApplicantService.simulatedError = .networkError(networkError)

        // When
        await viewModel.fetchApplicantDetailList()

        // Then
        XCTAssertTrue(viewModel.applicants.isEmpty, "Le ViewModel ne devrait pas avoir de candidats après un échec.")
        XCTAssertFalse(viewModel.isLoading, "isLoading devrait être false après une erreur.")
        XCTAssertEqual(viewModel.errorMessage, "Erreur réseau : La réponse du serveur est invalide.", "Le message d'erreur devrait refléter l'erreur réseau 500.")
    }

    // MARK: - Tests de filtrage des candidats

    func testFilterApplicants_SearchText() async {
        // Given
        let applicant1 = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        let applicant2 = ApplicantDetail(id: UUID(), firstName: "Alice", lastName: "Smith", email: "alice.smith@example.com", phone: "0987654321", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant1, applicant2]

        // When
        viewModel.searchText = "John"

        // Wait for filtered applicants to be updated
        let expectation = XCTestExpectation(description: "Filtered applicants should be updated based on search text")
        Task {
            // Boucle d'attente pour la mise à jour des `filteredApplicants`
            while viewModel.filteredApplicants.isEmpty {
                await Task.yield() // laisse les autres tâches s'effectuer
            }
            expectation.fulfill()
        }

        // Attend que la mise à jour soit terminée
        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.filteredApplicants.count, 1, "Le ViewModel devrait filtrer les candidats par le texte de recherche.")
        XCTAssertEqual(viewModel.filteredApplicants.first?.firstName, "John", "Le candidat filtré devrait être 'John'.")
    }

    func testFilterApplicants_ShowFavoritesOnly() async {
        // Given
        let applicant1 = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: true)
        let applicant2 = ApplicantDetail(id: UUID(), firstName: "Alice", lastName: "Smith", email: "alice.smith@example.com", phone: "0987654321", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant1, applicant2]

        // When
        viewModel.showFavoritesOnly = true

        // Crée une expectation pour vérifier que la mise à jour asynchrone est terminée
        let expectation = XCTestExpectation(description: "Filtrage des candidats favoris")

        // Attendre que la mise à jour asynchrone ait lieu
        Task { @MainActor in
            // Après que le filtrage est effectué
            if viewModel.filteredApplicants.count == 1 {
                expectation.fulfill()
            }
        }

        // Attendre jusqu'à 1 seconde pour que l'expectation soit remplie
        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.filteredApplicants.count, 1, "Le ViewModel ne devrait afficher que les candidats favoris.")
        XCTAssertEqual(viewModel.filteredApplicants.first?.firstName, "John", "Le candidat favori devrait être 'John'.")
    }

    // MARK: - Tests de basculement du statut favori

    func testToggleFavoriteStatus_Success() async throws {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant]

        // When
        await viewModel.toggleFavoriteStatus(for: applicant)

        // Then
        XCTAssertTrue(viewModel.applicants.first!.isFavorite, "Le statut 'favori' du candidat devrait être basculé avec succès.")
    }

    func testToggleFavoriteStatus_Failure_NetworkError() async throws {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant]

        // Simuler une erreur réseau (comme une erreur 500)
        let networkError = NSError(domain: "NetworkError", code: FakeResponseData.responseKo.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur réseau : La réponse du serveur est invalide."])
        mockApplicantService.simulatedError = .networkError(networkError)

        // When
        await viewModel.toggleFavoriteStatus(for: applicant)

        // Then
        XCTAssertFalse(viewModel.applicants.first!.isFavorite, "Le statut 'favori' du candidat ne devrait pas changer après une erreur réseau.")
        XCTAssertEqual(viewModel.errorMessage, "Erreur réseau : La réponse du serveur est invalide.", "Le message d'erreur devrait refléter l'échec réseau.")
    }

    // MARK: - Tests de suppression de candidats sélectionnés

    func testDeleteSelectedApplicants_Success() async throws {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant]
        viewModel.selectedApplicants = [applicant.id]

        // When
        await viewModel.deleteSelectedApplicants()

        // Then
        XCTAssertTrue(viewModel.applicants.isEmpty, "Les candidats sélectionnés devraient être supprimés avec succès.")
    }

    func testDeleteSelectedApplicants_Failure_NetworkError() async throws {
        // Given
        let applicant = ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "john.doe@example.com", phone: "1234567890", linkedinURL: nil, note: nil, isFavorite: false)
        viewModel.applicants = [applicant]
        viewModel.selectedApplicants = [applicant.id]

        // Simuler une erreur réseau de type ApplicantServiceError.networkError
        let networkError = NSError(domain: "NetworkError", code: FakeResponseData.responseKo.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur réseau : La réponse du serveur est invalide."])
        mockApplicantService.simulatedError = .networkError(networkError)

        // When
        await viewModel.deleteSelectedApplicants()

        // Forcer la mise à jour asynchrone
        await Task.yield()

        // Then
        XCTAssertFalse(viewModel.applicants.isEmpty, "Les candidats ne devraient pas être supprimés après une erreur réseau.")
        XCTAssertEqual(viewModel.errorMessage, "Erreur réseau : La réponse du serveur est invalide.", "Le message d'erreur devrait refléter l'échec réseau 500.")

        // Utilisation correcte de fulfillment dans un contexte async
        let expectation = XCTestExpectation(description: "Suppression du candidat après une erreur réseau")
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
    }


}
