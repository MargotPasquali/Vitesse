//
//  ApplicantListRowView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI
import VitesseModels

struct ApplicantListRowView: View {
    var applicant: ApplicantDetail
    var toggleFavorite: () -> Void // Ajoutez une fonction de bascule du favori

    var body: some View {
        HStack {
            Text(applicant.firstName)
                .font(.headline)
            Text(applicant.lastName)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()

            // Étoile cliquable pour basculer le statut de favori
            IsFavoriteView(isFavorite: applicant.isFavorite, toggleFavorite: toggleFavorite)
        }
    }
}

#Preview {
    ApplicantListRowView(applicant: ApplicantDetail(
        id: UUID(),
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        phone: "123-456-7890",
        linkedinURL: "https://linkedin.com/in/johndoe",
        note: "Great candidate",
        isFavorite: true
    ), toggleFavorite: {})
}
