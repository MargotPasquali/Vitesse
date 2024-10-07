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
    
    init(viewModel: ApplicantListViewModel) {
        self.viewModel = viewModel
        
        Task {
            await viewModel.fetchApplicantDetailList()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.filteredApplicants.isEmpty && (!viewModel.showFavoritesOnly || viewModel.applicants.contains { $0.isFavorite }) {
                    Text("Aucun candidat trouvé")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.regular)
                        .font(.headline)
                        .foregroundStyle(Color.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredApplicants, id: \.id) { applicant in
                            HStack {
                                if editMode?.wrappedValue.isEditing == true {
                                    Spacer()
                                    Image(systemName: viewModel.selectedApplicants.contains(applicant.id) ? "checkmark.circle.fill" : "circle")
                                        .onTapGesture {
                                            toggleSelection(for: applicant.id)
                                        }
                                }
                                
                                ZStack {
                                    ApplicantListRowView(applicant: applicant) {
                                        Task {
                                            await viewModel.toggleFavoriteStatus(for: applicant)
                                        }
                                    }
                                    
                                    NavigationLink(destination: ApplicantDetailView(
                                        viewModel: ApplicantDetailViewModel(applicant: applicant, isAdmin: isAdmin),
                                        toggleFavorite: {},
                                        applicant: .constant(applicant)
                                    )) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Candidats")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(editMode?.wrappedValue.isEditing == true ? "Done" : "Edit") {
                                withAnimation {
                                    editMode?.wrappedValue = editMode?.wrappedValue.isEditing == true ? .inactive : .active
                                }
                            }
                            .foregroundColor(.black)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if editMode?.wrappedValue.isEditing == true {
                                Button(action: deleteSelectedApplicants) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.black)

                                }
                            } else {
                                Button(action: {
                                    viewModel.showFavoritesOnly.toggle()
                                }) {
                                    Image(systemName: viewModel.showFavoritesOnly ? "star.fill" : "star")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 20))
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))

            
            // Overlay pour l'indicateur de chargement
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .font(Font.custom("Outfit", size: 18))
                    .fontWeight(.regular)
                    .font(.headline)
                    .scaleEffect(1.5)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
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
        viewModel.applicants = fakeApplicants
        
        return ApplicantListView(viewModel: viewModel)
    }
}
