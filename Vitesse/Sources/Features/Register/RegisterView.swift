//
// Copyright (C) 2024 Vitesse
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel() // Using @StateObject to hold the ViewModel
    @State private var showAlert = false // State to show the alert (success or error)
    @State private var navigateToLogin = false // State to trigger navigation to LoginView
    @State private var alertMessage = "" // Message to display in the alert
    @State private var isSuccess = false // State to determine the type of alert (success or error)
    
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
                    TextField("First Name", text: $viewModel.firstName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Last Name")
                        .font(.headline)
                    TextField("Last Name", text: $viewModel.lastName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Email")
                        .font(.headline)
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                    
                    Text("Password")
                        .font(.headline)
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    Text("Confirm Password")
                        .font(.headline)
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
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
                                isSuccess = true
                            } else {
                                alertMessage = "Account creation failed. Please try again."
                                isSuccess = false
                            }
                            showAlert = true
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
                    Alert(
                        title: Text(isSuccess ? "Success" : "Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            if isSuccess {
                                navigateToLogin = true // Trigger navigation to LoginView only on success
                            }
                        }
                    )
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
