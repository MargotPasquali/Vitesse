//
//  ApplicantDetail.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

struct ApplicantDetail: Identifiable, Codable {
    let id : String
    let phone: String
    let note: String
    let firstName: String
    let linkedinURL: String
    let applicantEmail: String  // Renommé pour éviter la confusion
    let lastName: String
}
