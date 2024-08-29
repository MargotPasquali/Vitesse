//
//  ApplicantListView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 26/08/2024.
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
                ForEach(viewModel.applicants) { applicant in
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
                            Text(applicant.phone ?? "No phone")
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
            Task {
                await viewModel.fetchApplicantDetailList()
            }
        }
    }
}

#Preview {
    ApplicantListView(viewModel: ApplicantListViewModel())
}
