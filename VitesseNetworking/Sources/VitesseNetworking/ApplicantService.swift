//
// Copyright (C) 2024 Vitesse
//


import Foundation
import VitesseModels

public protocol ApplicantService {
    var networkManager: NetworkManagerProtocol { get }
    func getCandidate() async throws -> [ApplicantDetail]

}

enum ApplicantServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

public final class RemoteApplicantService: ApplicantService {

    private static let url = URL(string: "http://127.0.0.1:8080")!

    public let networkManager: NetworkManagerProtocol

    public init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    public func getCandidate() async throws -> [ApplicantDetail] {

        var request = URLRequest(url: RemoteApplicantService.url.appendingPathComponent("account"))
        
        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
            print("Received response: \(response.statusCode)")
            print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            guard response.statusCode == 200 else {
                print("Non-200 status code received: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw ApplicantServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw ApplicantServiceError.serverError
                } else {
                    throw ApplicantServiceError.invalidResponse
                }
            }
            
            do {
                let applicantList = try JSONDecoder().decode([ApplicantDetail].self, from: data)
                print("Decoded account detail: \(applicantList)")
                return applicantList
            } catch let decodingError as DecodingError {
                print("Caught DecodingError: \(decodingError)")
                throw ApplicantServiceError.decodingError(decodingError)
            }
        } catch {
            print("Caught error in getCandidate(): \(error)")
            throw error
        }
    }
}
