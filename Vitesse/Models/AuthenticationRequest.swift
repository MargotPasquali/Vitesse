//
//  AuthenticationRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 20/08/2024.
//

import Foundation

struct AuthenticationRequest: Encodable {
    let email: String
    let password: String
}
