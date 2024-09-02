//
//  ApplicationCreationRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 29/08/2024.
//

import Foundation

struct ApplicantCreationRequest: Encodable {
    let email: String
    let note: String?
    let linkedinURL: String?
    let firstName: String
    let lastName: String
    let phone: String
}


