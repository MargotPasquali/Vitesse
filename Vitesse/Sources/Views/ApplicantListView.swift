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
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                
            } else if viewModel.filteredApplicants.isEmpty {
                Text("No applicant found")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                
            } else {
                List {
                    ForEach(viewModel.filteredApplicants, id: \.id) { applicant in
                        HStack {
                            if editMode?.wrappedValue.isEditing == true {
                                Image(systemName: viewModel.selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        toggleSelection(for: applicant.id)
                                    }
                            }
                            
                            ApplicantListRowView(applicant: applicant) {
                                viewModel.toggleFavoriteStatus(for: applicant)
                            }
                            
                            NavigationLink(destination: ApplicantDetailView(
                                viewModel: ApplicantDetailViewModel(applicant: applicant, isAdmin: isAdmin),
                                toggleFavorite: {},
                                applicant: .constant(applicant)
                            )) {
                                EmptyView()
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Candidates")
        .searchable(text: $viewModel.searchText)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if editMode?.wrappedValue.isEditing == true {
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
            print("ApplicantListView appeared")
            Task {
                await viewModel.fetchApplicantDetailList()
            }
        }
    }
    
    private func toggleSelection(for applicantID: UUID) {
        if viewModel.selectedApplicants.contains(applicantID) {
            viewModel.selectedApplicants.remove(applicantID)
        } else {
            viewModel.selectedApplicants.insert(applicantID)
        }
        print("Selected applicants: \(viewModel.selectedApplicants.count)")
    }
    
    private func deleteSelectedApplicants() {
        Task {
            await viewModel.deleteSelectedApplicants()
        }
    }
}

struct ApplicantListView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeApplicants = [
            ApplicantDetail(id: UUID(), firstName: "John", lastName: "Doe", email: "johndoe@example.com", phone: "123-456-7890", linkedinURL: nil, note: "Great candidate", isFavorite: false),
            ApplicantDetail(id: UUID(), firstName: "Jane", lastName: "Smith", email: "janesmith@example.com", phone: "987-654-3210", linkedinURL: nil, note: "Experienced developer", isFavorite: true),
            ApplicantDetail(id: UUID(), firstName: "Alice", lastName: "Johnson", email: "alice.johnson@example.com", phone: "555-123-4567", linkedinURL: nil, note: "Frontend expert", isFavorite: false)
        ]
        
        let viewModel = ApplicantListViewModel()
        viewModel.applicants = fakeApplicants // Inject fake data into the view model
        
        return ApplicantListView(viewModel: viewModel)
    }
}
