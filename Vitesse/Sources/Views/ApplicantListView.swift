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
                // Utilisation des filteredResults pour afficher les candidats
                ForEach(filteredResults, id: \.id) { applicant in
                    HStack {
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
                        }
                    }
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
        .onChange(of: viewModel.applicants) { newApplicants in
            print("Applicants in ViewModel have changed. Now have \(newApplicants.count) applicants.")
        }
    }
    
    // Filtrage des résultats
    private var filteredResults: [ApplicantDetail] {
        let results = searchResults
        if showFavoritesOnly {
            let filteredFavorites = results.filter { $0.isFavorite }
            print("Filtering to show only favorites: \(filteredFavorites.count) found")
            return filteredFavorites
        }
        print("Showing all applicants: \(results.count) applicants found")
        return results
    }

    private var searchResults: [ApplicantDetail] {
        if searchText.isEmpty {
            print("Search text is empty, showing all applicants")
            print("Applicants in ViewModel: \(viewModel.applicants.count)") // Ajoute ce log pour voir les candidats stockés dans le ViewModel
            return viewModel.applicants
        } else {
            let filteredSearch = viewModel.applicants.filter { applicant in
                applicant.firstName.lowercased().contains(searchText.lowercased()) ||
                applicant.lastName.lowercased().contains(searchText.lowercased())
            }
            print("Found \(filteredSearch.count) applicants matching search text")
            return filteredSearch
        }
    }

    // Basculer la sélection des candidats
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
        selectedApplicants.removeAll()
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}
