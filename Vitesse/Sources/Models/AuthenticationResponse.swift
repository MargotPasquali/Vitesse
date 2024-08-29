//
//  AuthenticationResponse.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

struct AuthenticationResponse: Codable {
    let token: String
    let isAdmin: Bool
}
