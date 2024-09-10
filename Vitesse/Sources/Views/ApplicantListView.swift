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
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @Environment(\.editMode) private var editMode
    @State private var selectedApplicants: Set<UUID> = []  // Stocke les candidats sélectionnés

    let isAdmin: Bool = true

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredResults, id: \.id) { applicant in
                    HStack {
                        // Affiche une case à cocher en mode d'édition
                        if editMode?.wrappedValue.isEditing == true {
                            Image(systemName: selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    toggleSelection(for: applicant.id)
                                }
                        }
                        
                        NavigationLink(destination: ApplicantDetailView(
                            viewModel: ApplicantDetailViewModel(applicant: applicant, isAdmin: isAdmin), toggleFavorite: {},
                            applicant: .constant(applicant)
                        )) {
                            ApplicantListRowView(applicant: applicant) {
                            
                                     viewModel.toggleFavoriteStatus(for: applicant)
                            
                            }
//                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    // Appliquer une couleur de fond différente pour les candidats sélectionnés
//                    .listRowBackground(selectedApplicants.contains(applicant.id) ? Color.blue.opacity(0.1) : Color(.systemBackground))

                }
            }
            .navigationTitle("Candidates")
            .searchable(text: $searchText)
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
                            showFavoritesOnly.toggle()
                        }) {
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchApplicantDetailList()
                }
            }
        }
    }

    // Filtrage des résultats en fonction des favoris
    private var filteredResults: [ApplicantDetail] {
        var results = searchResults
        if showFavoritesOnly {
            results = results.filter { $0.isFavorite }
        }
        return results
    }

    // Recherche des candidats
    private var searchResults: [ApplicantDetail] {
        if searchText.isEmpty {
            return viewModel.applicants
        } else {
            return viewModel.applicants.filter { applicant in
                applicant.firstName.lowercased().contains(searchText.lowercased()) ||
                applicant.lastName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    // Basculer la sélection des candidats en mode édition
    private func toggleSelection(for id: UUID) {
        if selectedApplicants.contains(id) {
            selectedApplicants.remove(id)
        } else {
            selectedApplicants.insert(id)
        }
    }

    // Suppression des candidats sélectionnés en mode d'édition
    private func deleteSelectedApplicants() {
        let applicantsToDelete = viewModel.applicants.filter { selectedApplicants.contains($0.id) }
        Task {
            for applicant in applicantsToDelete {
                await viewModel.deleteApplicant(applicant: applicant)
            }
        }
        // Réinitialiser la sélection après suppression
        selectedApplicants.removeAll()
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}

