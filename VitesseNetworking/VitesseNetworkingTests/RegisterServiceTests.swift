//
//  RegisterServiceTests.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 26/09/2024.
//

import XCTest
@testable import Vitesse
@testable import VitesseModels
@testable import VitesseTestUtilities

final class RegisterServiceTests: XCTestCase {
    
    var registerService: RegisterService!
    var mockNetworkManager: MockNetworkManager!  // Plus d'optionnel ici, il sera initialisé correctement
    
    override func setUp() {
        super.setUp()
        
        // Initialisation correcte du MockNetworkManager
        mockNetworkManager = MockNetworkManager()
        
        // Initialisation directe de RegisterService avec mockNetworkManager
        registerService = RemoteRegisterService(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        registerService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
}
