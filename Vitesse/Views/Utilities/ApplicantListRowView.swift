//
//  ApplicantListRowView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI

struct ApplicantListRowView: View {
    var applicant: ApplicantDetail

    var body: some View {
        HStack {
            Text(applicant.firstName)
                .font(.headline)
            Text(applicant.lastName)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            IsFavoriteView(isFavorite: applicant.isFavorite)
        }
//        .padding() // Régler pour augmenter l'espacement
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
    ))
}
