//
//  ApplicantDetail.swift
//  Vitesse
//
//  Created by Margot Pasquali on 21/08/2024.
//

import Foundation

public struct ApplicantDetail: Codable {
    public let phone: String
    public let note: String
    public let id : String
    public let firstName: String
    public let linkedinURL: String
    public let email: String
    public let lastName: String
}
