//
//  AuthenticationRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

public struct AuthenticationRequest: Encodable {
    public let email: String
    public let password: String
}
