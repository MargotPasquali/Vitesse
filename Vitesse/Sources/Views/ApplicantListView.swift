//
//  ApplicantListView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//


import SwiftUI
import VitesseModels

struct ApplicantListView: View {
    @ObservedObject var viewModel: ApplicantListViewModel

    @Environment(\.editMode) private var editMode

    let isAdmin: Bool = true

    var body: some View {
        List {
            // Utilisation des filteredResults pour afficher les candidats
            ForEach(viewModel.filteredApplicants, id: \.id) { applicant in
                HStack {
                    if editMode?.wrappedValue.isEditing == true {
                        Image(systemName: viewModel.selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                toggleSelection(for: applicant.id)
                            }
                    }

                    ZStack {
                        // Contenu de la ligne
                        ApplicantListRowView(applicant: applicant) {
                            viewModel.toggleFavoriteStatus(for: applicant)
                        }

                        // NavigationLink invisible
                        NavigationLink(destination: ApplicantDetailView(
                            viewModel: ApplicantDetailViewModel(applicant: applicant, isAdmin: isAdmin),
                            toggleFavorite: {},
                            applicant: .constant(applicant)
                        )) {
                            EmptyView() // Pas de contenu visible pour le lien
                        }
                        .opacity(0) // Rendre le NavigationLink invisible
                    }
                }
                .listRowInsets(EdgeInsets()) // Supprime les marges internes par défaut de chaque ligne
                .listRowSeparator(.hidden)  // Masquer le séparateur entre les lignes
            }
        }
        .padding(20)
        .listStyle(PlainListStyle())  // Utiliser un style de liste simplifié
        .navigationTitle("Candidates")
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()  // Bouton pour basculer en mode d'édition
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if editMode?.wrappedValue.isEditing == true {
                    // Bouton pour supprimer les candidats sélectionnés en mode d'édition
                    Button(action: deleteSelectedApplicants) {
                        Image(systemName: "trash")
                    }
                } else {
                    Button(action: {
                        viewModel.showFavoritesOnly.toggle()
                    }) {
                        Image(systemName: viewModel.showFavoritesOnly ? "star.fill" : "star")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchApplicantDetailList()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // Basculer la sélection des candidats
    private func toggleSelection(for applicant: UUID) {
        if viewModel.selectedApplicants.contains(applicant) {
            viewModel.selectedApplicants.remove(applicant)
        } else {
            viewModel.selectedApplicants.insert(applicant)
        }
    }

    // Suppression des candidats sélectionnés en mode d'édition
    private func deleteSelectedApplicants() {
        Task {
            await viewModel.deleteSelectedApplicants()
        }
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}
