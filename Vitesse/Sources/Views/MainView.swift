
import SwiftUI

struct MainView: View {

    @State
    private var isAuthenticated: Bool

    init(isAuthenticated: Bool = false) {
        self.isAuthenticated = isAuthenticated
    }

    var body: some View {
        if isAuthenticated {
            ApplicantListView(viewModel: ApplicantListViewModel())
        } else {
            LoginView(viewModel: LoginViewModel(), isAuthenticated: $isAuthenticated.wrappedValue)
        }
    }
}
