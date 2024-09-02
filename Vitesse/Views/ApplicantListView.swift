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
    @Environment(\.editMode) var editMode // Accès à l'EditMode via @Environment
    @State private var selectedApplicants: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { applicant in
                    if editMode?.wrappedValue == .active {
                        HStack {
                            Image(systemName: selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    toggleSelection(for: applicant.id)
                                }
                            ApplicantListRowView(applicant: applicant)
                        }
                    } else {
                        NavigationLink(destination: ApplicantDetailView(applicant: applicant)) {
                            ApplicantListRowView(applicant: applicant)
                        }
                        .buttonStyle(PlainButtonStyle()) // Faciliter le clic
                    }
                }
                .onDelete(perform: delete) // Activation de la suppression
            }
            .navigationTitle("Candidates")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchApplicantDetailList()
                }
            }
        }
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

    private func delete(at offsets: IndexSet) {
        if editMode?.wrappedValue == .active {
            for index in offsets {
                let applicant = searchResults[index]
                selectedApplicants.remove(applicant.id)
            }
        }
        viewModel.applicants.remove(atOffsets: offsets)
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}
