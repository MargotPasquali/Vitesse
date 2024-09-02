//
//  ApplicantDetailView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI

struct ApplicantDetailView: View {
    var applicant: ApplicantDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(applicant.firstName + " " + applicant.lastName)
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Text("Email")
                    .font(.subheadline)
                .foregroundColor(.blue)
                
                Text(applicant.email)
                    .font(.subheadline)
                .foregroundColor(.blue)
            }
            HStack {
                Text("Phone")
                    .font(.subheadline)
                .foregroundColor(.gray)
                if let phone = applicant.phone {
                    Text("Phone: \(phone)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Phone: No phone available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            if let linkedinURL = applicant.linkedinURL {
                Text("LinkedIn: \(linkedinURL)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("LinkedIn: No LinkedIn URL available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let note = applicant.note {
                Text("Note: \(note)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Note: No note available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Applicant Details")
    }
}

#Preview {
    ApplicantDetailView(applicant: ApplicantDetail(
            id: UUID(),  // Génère un UUID aléatoire pour l'aperçu
            firstName: "Rima",
            lastName: "Sidi",
            email: "sidi.rima@myemail.com",
            phone: nil,  // Utilisez nil pour indiquer l'absence de numéro de téléphone
            linkedinURL: nil,  // Utilisez nil pour indiquer l'absence d'URL LinkedIn
            note: "Great candidate with strong skills.",
            isFavorite: false  // Booléen, donc true ou false
        ))
}
