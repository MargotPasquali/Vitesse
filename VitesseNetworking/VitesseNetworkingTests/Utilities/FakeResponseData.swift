//
//  FakeResponseData.swift
//  VitesseNetworkingTests
//
//  Created by Margot Pasquali on 20/09/2024.
//
import Foundation

// MARK: - FakeResponseData

public class FakeResponseData {
    
    // MARK: - Simulated HTTP Responses
    
    public static let responseOk = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    public static let responseKo = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    public static let responseUnauthorized = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
    
    // MARK: - Simulated Error
    
    public class AuthenticationError: Error {}
    public static let error = AuthenticationError()
    
    // MARK: - Simulated Correct Data
    
    public static var authCorrectData: Data {
        let json = """
        {
            "token": "FB24D136-C228-491D-AB30-FDFD97009D19",
            "isAdmin": true
        }
        """
        return Data(json.utf8)
    }
    
    public static var getAllCandidatesCorrectData: Data {
        let json = """
        [
            {
                "id": "939C01F5-C9F0-4F65-9A7F-BA1B26D69C03",
                "firstName": "Martin",
                "lastName": "Deschamps",
                "email": "martin.deschamps@example.com",
                "phone": "0765432856",
                "linkedinURL": "https://linkedin.com/in/martindeschamps",
                "note": "Un excellent candidat avec beaucoup d'expérience.",
                "isFavorite": true
            },
            {
                "id": "AD82D248-1E32-490A-A678-9A56CD224368",
                "firstName": "Alice",
                "lastName": "Johnson",
                "email": "alice.johnson@example.com",
                "phone": "0787654321",
                "linkedinURL": "https://linkedin.com/in/alicejohnson",
                "note": "Expert en marketing digital.",
                "isFavorite": false
            }
        ]
        """
        return Data(json.utf8)
    }
    
    public static var postNewCandidateCorrectData: Data {
        let json = """
        [
            {
                "id": "533226E7-3C92-4499-8430-21386B0F2DFF",
                "firstName": "John",
                "lastName": "Doe",
                "email": "john.doe@example.com",
                "phone": "0712345678",
                "linkedinURL": "https://linkedin.com/in/johndoe",
                "note": "Nouveau candidat dans le secteur automobile.",
                "isFavorite": false
            }
        ]
        """
        return Data(json.utf8)
    }
    
    // MARK: - Simulated Incorrect Data
    
    public static let incorrectData = "incorrect json".data(using: .utf8)!
    
    // MARK: - Simulated Responses for Other Scenarios
    
    public static var deleteCandidateCorrectData: Data {
        let json = """
        {
            "message": "Candidate deleted successfully."
        }
        """
        return Data(json.utf8)
    }
    
    public static var putCandidateAsFavoriteCorrectData: Data {
        let json = """
        {
            "message": "Candidate favorite status updated."
        }
        """
        return Data(json.utf8)
    }
}
