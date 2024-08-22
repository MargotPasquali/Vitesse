//
// Copyright (C) 2024 Vitesse
//

import SwiftUI

@main
struct VitesseApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: LoginViewModel())
        }
    }
}
