//
//  RegisterViewModelTests.swift
//  VitesseTests
//
//  Created by Margot Pasquali on 25/09/2024.
//

import XCTest
@testable import VitesseTestUtilities
@testable import VitesseModels
@testable import Vitesse

class RegisterViewModelTests: XCTestCase {
    
    var viewModel: RegisterViewModel!
    var mockRegisterService: MockRegisterService!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        
        // Création des objets mocks
        mockNetworkManager = MockNetworkManager()
        mockRegisterService = MockRegisterService(networkManager: mockNetworkManager)
        
        // Initialisation du ViewModel avec le service d'inscription mocké
        viewModel = RegisterViewModel(registerService: mockRegisterService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRegisterService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests de validation du formulaire
    
    func testFormValidation_Success() {
        // Given
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // When
        let isValid = viewModel.isFormValid()
        
        // Then
        XCTAssertTrue(isValid, "Le formulaire devrait être valide")
    }
    
    func testFormValidation_MissingDetails() {
        // Given
        viewModel.firstName = ""
        viewModel.lastName = ""
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // When
        let isValid = viewModel.isFormValid()
        
        // Then
        XCTAssertFalse(isValid, "Le formulaire devrait être invalide lorsque des champs sont manquants")
    }
    
    func testFormValidation_PasswordsNotIdentical() {
        // Given
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password456" // Mots de passe différents
        
        // When
        let isValid = viewModel.isFormValid()
        
        // Then
        XCTAssertFalse(isValid, "Le formulaire devrait être invalide lorsque les mots de passe ne correspondent pas")
    }
    
    // MARK: - Tests d'inscription
    
    func testRegister_Success() async throws {
        // Given
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // Simule une inscription réussie
        mockRegisterService.error = nil
        let response = FakeResponseData.responseOk  // Simule une réponse 200
        let responseData = Data() // Simule des données correctes
        mockNetworkManager.simulatedResponse = (responseData, response)  // Utilise simulatedResponse
        
        // Création de l'attente
        let expectation = XCTestExpectation(description: "Inscription réussie")
        
        // When
        let success = await viewModel.register()
        
        // Then
        XCTAssertTrue(success, "L'inscription devrait réussir")
        
        Task { @MainActor in
            XCTAssertNil(viewModel.errorMessage, "Le message d'erreur devrait être nul après un succès")
            XCTAssertFalse(viewModel.isLoading, "isLoading devrait être false après une inscription réussie")
            expectation.fulfill() // Marque l'attente comme satisfaite
        }
        
        await fulfillment(of: [expectation], timeout: 1.0) // Attend que la tâche se termine
    }

    func testRegister_Failure_MissingDetails() async throws {
        // Given
        viewModel.firstName = ""
        viewModel.lastName = ""
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // Création de l'attente
        let expectation = XCTestExpectation(description: "Échec de l'inscription avec des champs manquants")
        
        // When
        let success = await viewModel.register()
        
        // Then
        XCTAssertFalse(success, "L'inscription devrait échouer à cause des champs manquants")
        
        Task { @MainActor in
            XCTAssertEqual(viewModel.errorMessage, RegisterViewModel.RegisterViewModelError.missingAccountDetails.localizedDescription, "Le message d'erreur devrait indiquer que des détails sont manquants")
            expectation.fulfill() // Marque l'attente comme satisfaite
        }
        
        await fulfillment(of: [expectation], timeout: 1.0) // Attend que la tâche se termine
    }
    
    func testRegister_Failure_InvalidResponse() async throws {
        // Given
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // Simule une réponse invalide du service d'inscription
        mockRegisterService.error = .invalidResponse
        
        // Création de l'attente
        let expectation = XCTestExpectation(description: "Échec de l'inscription avec une réponse invalide")
        
        // When
        let success = await viewModel.register()
        
        // Then
        XCTAssertFalse(success, "L'inscription devrait échouer avec une réponse invalide")
        
        Task { @MainActor in
            XCTAssertEqual(viewModel.errorMessage, "Réponse invalide du serveur. Veuillez réessayer plus tard.", "Le message d'erreur devrait correspondre à une réponse invalide")
            XCTAssertFalse(viewModel.isLoading, "isLoading devrait être false après l'échec")
            expectation.fulfill() // Marque l'attente comme satisfaite
        }
        
        await fulfillment(of: [expectation], timeout: 1.0) // Attend que la tâche se termine
    }
    
    func testRegister_Failure_NetworkError() async throws {
        // Given
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // Simule une réponse 500 du serveur avec des données vides
        let response = FakeResponseData.responseKo  // Utilisation de la réponse 500
        let responseData = Data() // Pas de données nécessaires pour ce test
        mockNetworkManager.simulatedResponse = (responseData, response)  // Simule la réponse réseau avec simulatedResponse
        
        // Création de l'attente
        let expectation = XCTestExpectation(description: "Échec de l'inscription avec une erreur réseau 500")
        
        // When
        let success = await viewModel.register()
        
        // Then
        XCTAssertFalse(success, "L'inscription devrait échouer avec une erreur réseau 500")
        
        Task { @MainActor in
            XCTAssertEqual(viewModel.errorMessage, "Une erreur s'est produite sur le serveur. Veuillez réessayer plus tard.", "Le message d'erreur devrait correspondre à une erreur réseau 500")
            XCTAssertFalse(viewModel.isLoading, "isLoading devrait être false après l'échec")
            expectation.fulfill() // Marque l'attente comme satisfaite
        }
        
        await fulfillment(of: [expectation], timeout: 1.0) // Attend que la tâche se termine
    }

}
