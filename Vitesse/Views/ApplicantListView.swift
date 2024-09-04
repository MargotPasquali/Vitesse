//
//  ApplicantListView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
//

import SwiftUI

struct ApplicantListView: View {
    @ObservedObject var viewModel: ApplicantListViewModel
    @State private var searchText = ""
    @Environment(\.editMode) var editMode
    @State private var selectedApplicants: Set<UUID> = []
    @State private var showFavoritesOnly = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredResults, id: \.id) { applicant in
                    HStack {
                        if editMode?.wrappedValue == .active {
                            Image(systemName: selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    toggleSelection(for: applicant.id)
                                }
                        }

                        NavigationLink(destination: ApplicantDetailView(applicant: applicant)) {
                            ApplicantListRowView(applicant: applicant)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Candidates")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if editMode?.wrappedValue == .active && !selectedApplicants.isEmpty {
                        Button(action: toggleFavoriteStatus) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
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

    private var filteredResults: [ApplicantDetail] {
        let results = searchResults
        if showFavoritesOnly {
            return results.filter { $0.isFavorite }
        }
        return results
    }

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

    private func toggleSelection(for id: UUID) {
        if selectedApplicants.contains(id) {
            selectedApplicants.remove(id)
        } else {
            selectedApplicants.insert(id)
        }
    }

    private func toggleFavoriteStatus() {
        for id in selectedApplicants {
            if let applicant = viewModel.applicants.first(where: { $0.id == id }) {
                Task {
                    await viewModel.toggleFavoriteStatus(for: applicant)
                }
            }
        }
        selectedApplicants.removeAll()
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}
