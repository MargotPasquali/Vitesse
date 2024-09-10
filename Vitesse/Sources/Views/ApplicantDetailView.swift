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
    var toggleFavorite: () -> Void // Ajoutez une fonction de bascule du favori

    @Binding var applicant: ApplicantDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if isEditing {
                    TextField("First Name", text: $viewModel.applicant.firstName)
                    TextField("Last Name", text: $viewModel.applicant.lastName)
                } else {
                    Text(viewModel.applicant.firstName + " " + viewModel.applicant.lastName)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()

                // Basculer l'état favori uniquement en mode d'édition et si l'utilisateur est admin
                if viewModel.isAdmin && isEditing {
                    IsFavoriteView(isFavorite: viewModel.applicant.isFavorite) {
                        Task {
                            await viewModel.toggleFavorite() // Appel à la méthode toggleFavorite
                        }
                    }
                }
                IsFavoriteView(isFavorite: applicant.isFavorite, toggleFavorite: toggleFavorite)

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
                if let phone = viewModel.applicant.phone {
                    if isEditing {
                        TextField("Phone", text: Binding($viewModel.applicant.phone, default: ""))
                    } else {
                        Text("\(phone)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("No phone available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // Autres champs similaires (LinkedIn URL, Note)

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
}

extension Binding {
    // Binding pour gérer le nil
    init(_ source: Binding<Value?>, default: Value) {
        self.init(
            get: { source.wrappedValue ?? `default` },
            set: { source.wrappedValue = $0 }
        )
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
