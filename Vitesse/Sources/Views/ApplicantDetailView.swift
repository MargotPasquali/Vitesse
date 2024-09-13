//
//  ApplicantDetailView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI
import VitesseModels

struct ApplicantDetailView: View {

    @ObservedObject var viewModel: ApplicantDetailViewModel

    @State private var isEditing = false // État pour gérer le mode d'édition

    var toggleFavorite: () -> Void // Fonction de bascule du favori

    @Binding var applicant: ApplicantDetail

    @State private var favoriteChanged = false // État local pour déclencher l'animation

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                    Spacer()
                }

                // Afficher l'étoile une seule fois avec les bonnes conditions
                .overlay(alignment: .topTrailing) {
                    if viewModel.isAdmin {
                        // Rendre l'étoile cliquable si l'utilisateur est admin
                        Button(action: {
                            Task {
                                await toggleFavoriteAction()
                            }
                        }) {
                            Image(systemName: applicant.isFavorite ? "star.fill" : "star")
                                .foregroundColor(applicant.isFavorite ? Color.yellow : Color.gray) // Changement de couleur
                                .scaleEffect(favoriteChanged ? 1.2 : 1.0) // Animation d'échelle
                        }
                        .offset(x: -130, y: 4) // Ajuster la position de l'étoile
                    }
                }
            }

            HStack {
                Spacer()
                if isEditing {
                    TextField("First Name", text: $viewModel.applicant.firstName)
                    TextField("Last Name", text: $viewModel.applicant.lastName)
                } else {
                    Text(viewModel.applicant.firstName + " " + viewModel.applicant.lastName)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
            }

            HStack {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                if isEditing {
                    TextField("Email", text: $viewModel.applicant.email)
                } else {
                    Text(viewModel.applicant.email)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            HStack {
                Text("Phone")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isEditing {
                    TextField("Phone", text: Binding(
                        get: { viewModel.applicant.phone ?? "" },
                        set: { viewModel.applicant.phone = $0 }
                    ))
                } else {
                    Text(viewModel.applicant.phone ?? "No phone available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("LinkedIn")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isEditing {
                    TextField("LinkedIn", text: Binding(
                        get: { viewModel.applicant.linkedinURL ?? "" },
                        set: { viewModel.applicant.linkedinURL = $0 }
                    ))
                } else {
                    Text(viewModel.applicant.linkedinURL ?? "No LinkedIn URL available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Note")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isEditing {
                    TextField("Note", text: Binding(
                        get: { viewModel.applicant.note ?? "" },
                        set: { viewModel.applicant.note = $0 }
                    ))
                } else {
                    Text(viewModel.applicant.note ?? "No Note available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Applicant Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            Task {
                                await viewModel.updateApplicantDetails() // Sauvegarder les modifications
                            }
                        }
                        isEditing.toggle() // Bascule le mode d'édition
                    }
                }
            }
        }
    }
    
    private func toggleFavoriteAction() async {
        withAnimation(.easeInOut(duration: 0.3)) {
            favoriteChanged.toggle() // Animation de mise à l'échelle
        }
        // Attendre l'API avant de modifier l'état local
        await viewModel.toggleFavorite()
    }
}

#Preview {
    @State var applicant = ApplicantDetail(
        id: UUID(),
        firstName: "Rima",
        lastName: "Sidi",
        email: "sidi.rima@myemail.com",
        phone: nil,
        linkedinURL: nil,
        note: "Great candidate with strong skills.",
        isFavorite: false
    )

    return ApplicantDetailView(
        viewModel: ApplicantDetailViewModel(
            applicant: applicant,
            isAdmin: true
        ), toggleFavorite: {},
        applicant: $applicant
    )
}
