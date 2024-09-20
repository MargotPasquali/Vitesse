//
//  LoginView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import SwiftUI

struct LoginView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @ObservedObject var viewModel: LoginViewModel
    @State private var showApplicantList = false
    
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
                        .font(.headline)
                    
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
                        .font(.headline)
                    
                    SecureField("Mot de passe", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
                // Sign In Button
                Button(action: {
                    Task {
                        do {
                            try await viewModel.login()  // Essaye de se connecter
                            showApplicantList = true // Déclenche la navigation après succès
                        } catch {
                            // Handle error if needed
                            print("Login failed with error: \(error.localizedDescription)")
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
                
                // Register Button
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
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
