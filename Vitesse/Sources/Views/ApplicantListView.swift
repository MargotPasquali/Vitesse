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
        .searchable(text: $viewModel.searchTerms, placement: .navigationBarDrawer(displayMode: .always))
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
        //        .onChange(of: viewModel.applicants) { newApplicants in
        //            print("Applicants in ViewModel have changed. Now have \(newApplicants.count) applicants.")
        //        }
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
