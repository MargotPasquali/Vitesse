//
//  AuthenticationResponse.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

public struct AuthenticationResponse: Codable {
    public let token: String
    public let isAdmin: Bool
}
