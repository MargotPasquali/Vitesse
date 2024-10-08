//
//  RegisterView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel() // Using @StateObject to hold the ViewModel
    @State private var showAlert = false // State to show the alert (success or error)
    @State private var navigateToLogin = false // State to trigger navigation to LoginView
    @State private var alertMessage = "" // Message to display in the alert
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
                Text("Création de compte")
                    .font(Font.custom("Outfit", size: 30))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Prénom")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                        .font(.headline)
                    TextField("", text: $viewModel.firstName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Nom de Famille")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                        .font(.headline)
                    TextField("", text: $viewModel.lastName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Email")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                        .font(.headline)
                    TextField("", text: $viewModel.email)
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
                    SecureField("", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    Text("Confirmation du mot de passe")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.medium)
                        .font(.headline)
                    SecureField("", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                
                // Create Button
                Button(action: {
                    Task {
                        if viewModel.isFormValid() {
                            let registrationSuccess = await viewModel.register()
                            
                            if registrationSuccess {
                                alertMessage = "Votre compte a été créé avec succès"
                                showAlert = true
                                navigateToLogin = true
                            } else {
                                alertMessage = viewModel.errorMessage ?? "La création de compte a échoué. Veuillez réessayer."
                                showAlert = true
                            }
                        } else {
                            viewModel.errorMessage = "Veuillez remplir tous les champs correctement"
                        }
                    }
                }) {
                    Text("Créer un compte")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid() ? Color.black : Color.gray)
                        .cornerRadius(8)
                        .fontWeight(.bold)
                        .font(Font.custom("Outfit", size: 20))
                }
                .disabled(!viewModel.isFormValid())
                .alert(isPresented: $showAlert) {
                    if navigateToLogin {
                        return Alert(
                            title: Text("Bienvenue"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                navigateToLogin = true // Trigger navigation to LoginView
                            }
                        )
                    } else {
                        return Alert(
                            title: Text("Erreur"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                // Navigation to LoginView
                NavigationLink(
                    destination: LoginView(viewModel: LoginViewModel()),
                    isActive: $navigateToLogin,
                    label: { EmptyView() }
                )
                
            }
            .padding(.horizontal, 40)
            .font(Font.custom("Outfit", size: 18))
            .fontWeight(.light)
        }
        .onTapGesture {
            // Hide keyboard
        }
    }
}

#Preview {
    RegisterView()
}
