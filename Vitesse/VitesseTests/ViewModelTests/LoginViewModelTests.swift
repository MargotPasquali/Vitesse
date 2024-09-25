//
//  LoginViewModelTests.swift
//  VitesseTests
//
//  Created by Margot Pasquali on 21/09/2024.
//

import XCTest

@testable import Vitesse
@testable import VitesseModels
@testable import VitesseNetworking

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockAuthenticationService: MockAuthenticationService!
    var mockApplicantService: MockApplicantService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockAuthenticationService = MockAuthenticationService(networkManager: mockNetworkManager)
        mockApplicantService = MockApplicantService(networkManager: mockNetworkManager)
        viewModel = LoginViewModel(authenticationService: mockAuthenticationService, applicantService: mockApplicantService) { _ in }
    }

    // Tests à venir ici
}
