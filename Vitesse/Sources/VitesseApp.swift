//
//  VitesseApp.swift
//  Vitesse
//
//  Created by Margot Pasquali on 19/08/2024.
//

import SwiftUI

@main
struct VitesseApp: App {
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                    }
            } else {
                LoginView(viewModel: LoginViewModel())
            }
        }
    }
}
