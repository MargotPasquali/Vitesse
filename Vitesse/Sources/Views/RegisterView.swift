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
                
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("First Name")
                        .font(.headline)
                    TextField("", text: $viewModel.firstName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Last Name")
                        .font(.headline)
                    TextField("", text: $viewModel.lastName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Email")
                        .font(.headline)
                    TextField("", text: $viewModel.email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                    
                    Text("Password")
                        .font(.headline)
                    SecureField("", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    Text("Confirm Password")
                        .font(.headline)
                    SecureField("", text: $viewModel.confirmPassword)
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
                
                // Create Button
                Button(action: {
                    Task {
                        if viewModel.isFormValid() {
                            let registrationSuccess = await viewModel.register()
                            
                            if registrationSuccess {
                                alertMessage = "Your account has been created successfully!"
                                showAlert = true
                                navigateToLogin = true
                            } else {
                                alertMessage = viewModel.errorMessage ?? "Account creation failed. Please try again."
                                showAlert = true
                            }
                        } else {
                            viewModel.errorMessage = "Please fill in all fields correctly."
                        }
                    }
                }) {
                    Text("Create")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid() ? Color.black : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isFormValid())
                .alert(isPresented: $showAlert) {
                    if navigateToLogin {
                        return Alert(
                            title: Text("Success"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                navigateToLogin = true // Trigger navigation to LoginView
                            }
                        )
                    } else {
                        return Alert(
                            title: Text("Error"),
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
        }
        .onTapGesture {
            // Hide keyboard
        }
    }
}

#Preview {
    RegisterView()
}
