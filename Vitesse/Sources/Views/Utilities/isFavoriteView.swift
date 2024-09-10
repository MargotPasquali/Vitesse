//
//  isFavoriteView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 02/09/2024.
//

import SwiftUI

struct IsFavoriteView: View {
    let isFavorite: Bool
    var toggleFavorite: () -> Void
    
    var body: some View {
        Image(systemName: isFavorite ? "star.fill" : "star")
            .foregroundColor(isFavorite ? .yellow : .gray)
            .onTapGesture {
                toggleFavorite()
            }
    }
}

#Preview {
    IsFavoriteView(isFavorite: true) {}
}
