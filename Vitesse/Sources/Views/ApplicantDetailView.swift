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
    @State private var isEditing = false
    var toggleFavorite: () -> Void
    
    @Binding var applicant: ApplicantDetail
    @State private var favoriteChanged = false
    @Environment(\.presentationMode) var presentationMode // Utilisé pour contrôler la navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    Spacer()
                }
                
                .overlay(alignment: .topTrailing) {
                    if viewModel.isAdmin {
                        Image(systemName: applicant.isFavorite ? "star.fill" : "star")
                            .foregroundColor(applicant.isFavorite ? Color.yellow : Color.gray)
                            .font(.system(size: 28))
                            .scaleEffect(favoriteChanged ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: favoriteChanged)
                            .offset(x: -116, y: 1)
                            .onTapGesture {
                                if isEditing {
                                    Task {
                                        await toggleFavoriteAction()
                                    }
                                }
                            }
                    }
                }
            }
            
            HStack {
                Spacer()
                if isEditing {
                    TextField("First Name", text: $viewModel.applicant.firstName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Last Name", text: $viewModel.applicant.lastName)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(viewModel.applicant.firstName + " " + viewModel.applicant.lastName)
                        .font(Font.custom("Outfit", size: 20))
                        .fontWeight(.bold)
                        .font(.headline)
                }
                Spacer()
            }
            .padding(.vertical, 10.0)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 3)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("À propos :")
                        .font(Font.custom("Outfit", size: 20))
                        .fontWeight(.bold)
                        .padding(.vertical, 13.0)
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.black)
                        if isEditing {
                            TextField("Email", text: $viewModel.applicant.email)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(viewModel.applicant.email)
                                .font(Font.custom("Outfit", size: 18))
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.black)
                        if isEditing {
                            TextField("Phone", text: Binding(
                                get: { viewModel.applicant.phone ?? "" },
                                set: { viewModel.applicant.phone = $0 }
                            )).textFieldStyle(.roundedBorder)
                        } else {
                            Text(viewModel.applicant.phone ?? "No phone available")
                                .font(Font.custom("Outfit", size: 18))
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.black)
                        if isEditing {
                            TextField("Note", text: Binding(
                                get: { viewModel.applicant.note ?? "" },
                                set: { viewModel.applicant.note = $0 }
                            )).textFieldStyle(.roundedBorder)
                        } else {
                            Text(viewModel.applicant.note ?? "No Note available")
                                .font(Font.custom("Outfit", size: 18))
                                .foregroundStyle(Color.black)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .frame(height: 400)
        }
        .padding()
        .navigationTitle("Applicant Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Cacher le bouton "Back" par défaut
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Revenir à la vue précédente
                }) {
                    HStack {
                        Image(systemName: "chevron.left") // Icône de flèche
                            .font(.system(size: 18, weight: .bold))
                        Text("Back")
                            .font(Font.custom("Outfit", size: 18))
                    }
                    .foregroundColor(.black) // Couleur du texte et de l'icône
                }
            }
            
            if viewModel.isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            Task {
                                await viewModel.updateApplicantDetails()
                            }
                        }
                        isEditing.toggle()
                    }
                    .foregroundColor(.black) // Ajouter la couleur noire au bouton "Edit" ou "Save"
                }
            }
        }
        
        if let linkedinURL = viewModel.applicant.linkedinURL, !linkedinURL.isEmpty {
            HStack {
                Button(action: {
                    if let url = URL(string: linkedinURL) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Voir le profil LinkedIn")
                        .frame(maxWidth: .infinity)
                        .font(Font.custom("Outfit", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                }
            }
        } else {
            HStack {
                Spacer()
                Text("Pas de profil LinkedIn")
                    .font(Font.custom("Outfit", size: 20))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
    
    private func toggleFavoriteAction() async {
        withAnimation(.easeInOut(duration: 0.3)) {
            favoriteChanged.toggle()
        }
        await viewModel.toggleFavorite()
        withAnimation(.easeInOut(duration: 0.3)) {
            favoriteChanged.toggle()
        }
    }
}

#Preview {
    @State var applicant = ApplicantDetail(
        id: UUID(),
        firstName: "Rima",
        lastName: "Sidi",
        email: "sidi.rima@myemail.com",
        phone: nil,
        linkedinURL: "https:linked.com/myprofil",
        note: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
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
