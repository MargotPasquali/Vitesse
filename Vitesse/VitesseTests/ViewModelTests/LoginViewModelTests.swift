//
//  LoginViewModelTests.swift
//  VitesseTests
//
//  Created by Margot Pasquali on 21/09/2024.
//

import XCTest
@testable import VitesseTestUtilities
@testable import VitesseModels
@testable import Vitesse

class LoginViewModelTests: XCTestCase {
    
    var viewModel: LoginViewModel!
    var mockAuthenticationService: MockAuthenticationService!
    var mockApplicantService: MockApplicantService!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        
        // Create mock objects
        mockNetworkManager = MockNetworkManager()
        mockAuthenticationService = MockAuthenticationService(networkManager: mockNetworkManager)
        mockApplicantService = MockApplicantService(networkManager: mockNetworkManager)
        
        // Initialize the view model with the mock services
        viewModel = LoginViewModel(authenticationService: mockAuthenticationService, applicantService: mockApplicantService) { _ in }
    }
    
    override func tearDown() {
        // Clean up after each test
        viewModel = nil
        mockAuthenticationService = nil
        mockApplicantService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testValidateEmail_ValidEmail() {
        let validEmail = "test@example.com"
        XCTAssertTrue(LoginViewModel.validateEmail(validEmail))
    }
    
    func testValidateEmail_InvalidEmail() {
        let invalidEmail = "invalid-email"
        XCTAssertFalse(LoginViewModel.validateEmail(invalidEmail))
    }
    
    func testValidateEmail_EmailWithConsecutiveDots() {
        let invalidEmail = "test..email@example.com"
        XCTAssertFalse(LoginViewModel.validateEmail(invalidEmail))
    }
    
    // MARK: - Authentication Tests
    
    func testPerformAuthentication_Success() async throws {
        // Given
        viewModel.email = "admin@vitesse.com"
        viewModel.password = "test123"
        
        // Set mock authentication to succeed
        mockAuthenticationService.authResponse = AuthenticationResponse(token: "validToken", isAdmin: true)
        
        // When
        try await viewModel.performAuthentication()
        
        // Then
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }
    
    func testPerformAuthentication_Failure() async {
        // Given
        viewModel.email = "admin@vitesse.com"
        viewModel.password = "invalidPassword"
        
        // Set mock authentication to fail
        mockAuthenticationService.error = .invalidCredentials
        
        // Expect error to be thrown
        do {
            try await viewModel.performAuthentication()
            XCTFail("Expected an error but none was thrown")
        } catch {
            XCTAssertEqual(error as? LoginViewModel.LoginViewModelError, LoginViewModel.LoginViewModelError.authenticationFailed, "Expected authenticationFailed error")
        }
    }
    
    // MARK: - Login Process Tests
    
    func testLogin_Success() async throws {
        // Given
        viewModel.email = "admin@vitesse.com"
        viewModel.password = "validPassword"
        
        // Set mock authentication to succeed
        mockAuthenticationService.authResponse = AuthenticationResponse(token: "validToken", isAdmin: true)
        
        // When
        try await viewModel.login()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after login completes")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on successful login")
    }
    
    func testLogin_Failure() async {
        // Given
        viewModel.email = "admin@vitesse.com"
        viewModel.password = "invalidPassword"
        
        // Set mock authentication to fail
        mockAuthenticationService.error = .invalidCredentials
        
        // When
        do {
            try await viewModel.login()
            XCTFail("Expected an error but none was thrown")
        } catch {
            // Then
            XCTAssertFalse(viewModel.isLoading, "isLoading should be false after login fails")
            
            // Compare localized error message instead of the raw error
            XCTAssertEqual(viewModel.errorMessage, LoginViewModel.LoginViewModelError.authenticationFailed.localizedDescription, "Error message should reflect authentication failure")
        }
    }

    
    func testLogin_MissingAccountDetails() async {
        // Given
        viewModel.email = ""
        viewModel.password = ""
        
        // When
        do {
            try await viewModel.login()
            XCTFail("Expected an error but none was thrown")
        } catch {
            // Then
            XCTAssertFalse(viewModel.isLoading, "isLoading should be false after login fails")
            XCTAssertEqual(error as? LoginViewModel.LoginViewModelError, LoginViewModel.LoginViewModelError.authenticationFailed, "Expected missing account details error")
        }
    }
}
