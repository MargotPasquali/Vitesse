//
//  ApplicantDetail.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

struct ApplicantDetail: Identifiable, Codable {
    var id: UUID?  // UUID optionnel
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?  // Optionnel
    var linkedinURL: String?  // Optionnel
    var note: String?  // Optionnel
    var isFavorite: Bool
}
