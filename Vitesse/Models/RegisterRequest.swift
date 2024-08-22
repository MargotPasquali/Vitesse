//
//  RegisterRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 21/08/2024.
//

import Foundation

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}
