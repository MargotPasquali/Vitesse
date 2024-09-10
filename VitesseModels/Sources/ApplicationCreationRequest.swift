//
//  ApplicationCreationRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 29/08/2024.
//

import Foundation

public struct ApplicantCreationRequest: Encodable {
    public let email: String
    public let note: String?
    public let linkedinURL: String?
    public let firstName: String
    public let lastName: String
    public let phone: String
    
    
    public init(email: String, note: String?, linkedinURL: String?, firstName: String, lastName: String, phone: String) {
        self.email = email
        self.note = note
        self.linkedinURL = linkedinURL
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
    }
}

