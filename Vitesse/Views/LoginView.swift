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
    @State private var showDestination = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 20) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                    
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Email/Username")
                            .font(.headline)
                        
                        TextField("Adresse email", text: $viewModel.username)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                        
                        Text("Password")
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
                            .padding()
                    }
                    
                    // Sign In Button
                    Button(action: {
                        Task {
                            // try await viewModel.login()
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    
                    // Register Button (now inside the VStack, below Sign In)
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
            }
            .onTapGesture {
                // Hide keyboard
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
