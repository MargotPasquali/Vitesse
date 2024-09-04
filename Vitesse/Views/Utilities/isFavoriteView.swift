//
//  isFavoriteView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI

struct IsFavoriteView: View {
    let isFavorite: Bool
    var body: some View {
        if isFavorite {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow) 
        } else {
            Image(systemName: "star")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    IsFavoriteView(isFavorite: true)
}
