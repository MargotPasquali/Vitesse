//
//  RegisterRequest.swift
//  Vitesse
//
//  Created by Margot Pasquali on 21/08/2024.
//

import Foundation

public struct RegisterRequest: Encodable {
    public let username: String
    public let password: String
    public let firstName: String
    public let lastName: String
    
    
    
    public init(username: String, password: String, firstName: String, lastName: String) {
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}
