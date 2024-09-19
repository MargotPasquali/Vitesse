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
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 3)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            HStack {
                Text(applicant.firstName)
                    .font(Font.custom("Outfit", size: 18))
                    .fontWeight(.regular)
                    .font(.headline)
                Text(applicant.lastName)
                    .font(Font.custom("Outfit", size: 18))
                    .fontWeight(.regular)
                    .font(.headline)
                
                Spacer()

                // Étoile cliquable pour basculer le statut de favori
                IsFavoriteView(isFavorite: applicant.isFavorite, toggleFavorite: toggleFavorite)
                    .font(.system(size: 23))

            }
            .padding(20.0)
        }

        .padding(.horizontal, 20)

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
