//
//  ApplicantDetail.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import Foundation

public class ApplicantDetail: Identifiable, Codable, Equatable {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public var phone: String?
    public var linkedinURL: String?
    public var note: String?
    
    // Propriété réactive avec didSet
    public var isFavorite: Bool {
        didSet {
            print("isFavorite a changé pour \(isFavorite)")
            // Ajoutez toute logique que vous souhaitez exécuter lorsque isFavorite change
        }
    }

    public init(id: UUID = UUID(), firstName: String, lastName: String, email: String, phone: String? = nil, linkedinURL: String? = nil, note: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.linkedinURL = linkedinURL
        self.note = note
        self.isFavorite = isFavorite
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(linkedinURL, forKey: .linkedinURL)
        try container.encode(note, forKey: .note)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
    
    // MARK: - Decodable
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        linkedinURL = try container.decodeIfPresent(String.self, forKey: .linkedinURL)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)

        print("Successfully decoded: \(firstName) \(lastName)")
    }

    // MARK: - Conformance to Equatable
        public static func ==(lhs: ApplicantDetail, rhs: ApplicantDetail) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.firstName == rhs.firstName &&
                   lhs.lastName == rhs.lastName &&
                   lhs.email == rhs.email &&
                   lhs.phone == rhs.phone &&
                   lhs.linkedinURL == rhs.linkedinURL &&
                   lhs.note == rhs.note &&
                   lhs.isFavorite == rhs.isFavorite
        }
    
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, phone, linkedinURL, note, isFavorite
    }
}
