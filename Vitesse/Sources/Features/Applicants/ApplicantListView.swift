//
// Copyright (C) 2024 Vitesse
//

import SwiftUI

struct ApplicantListView: View {
    
    @ObservedObject var viewModel: ApplicantListViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Candidates")
                    .font(.headline)
                    .padding([.horizontal])
                
                // Affichage de la liste des candidats
                ForEach(viewModel.applicants, id: \.id) { applicant in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(applicant.firstName)
                                .font(.headline)
                            Text(applicant.lastName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(applicant.email)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(applicant.phone)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding([.horizontal])
                }
            }
        }
        .onAppear {
            // Charger la liste des candidats à l'apparition de la vue
            Task {
                await viewModel.fetchApplicantDetailList()
            }
        }
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}

