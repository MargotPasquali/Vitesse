//
//  LoginView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    @State private var showApplicantList = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) { // Ajustez l'espacement ici pour réduire l'espace
                Image("Logo Recrutement")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350)
                
                Text("Connexion")
                    .font(Font.custom("Outfit", size: 30))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) { // Ajustez l'espacement interne ici
                    Text("Email")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                    
                    TextField("Adresse email", text: $viewModel.email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                    
                    Text("Mot de passe")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                    
                    SecureField("Mot de passe", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                // Bouton de connexion
                Button(action: {
                    Task {
                        do {
                            try await viewModel.login()  // Essaye de se connecter
                            showApplicantList = true // Déclenche la navigation après succès
                        } catch {
                            // On gère l'affichage de l'erreur ici
                            viewModel.errorMessage = (error as? LoginViewModel.LoginViewModelError)?.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }) {
                    Text("Se connecter")
                        .foregroundColor(.white)
                        .font(Font.custom("Outfit", size: 20))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                
                // Bouton d'enregistrement
                NavigationLink(destination: RegisterView()) {
                    Text("S'enregistrer")
                        .foregroundColor(.black)
                        .font(Font.custom("Outfit", size: 20))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                
                // Navigation vers ApplicantListView si le login est réussi
                NavigationLink(destination: ApplicantListView(viewModel: ApplicantListViewModel()), isActive: $showApplicantList) {
                    EmptyView()  // Vue vide utilisée pour déclencher la navigation
                }
            }
            .padding(.horizontal, 40)
            .navigationBarBackButtonHidden(true)
            .font(Font.custom("Outfit", size: 18))
            .fontWeight(.regular)
            // Affichage de l'alerte en cas d'erreur
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Un problème est survenu"),
                    message: Text(viewModel.errorMessage ?? "Une erreur est survenue. Veuillez réessayer."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}


#Preview {
    LoginView(viewModel: LoginViewModel())
}
