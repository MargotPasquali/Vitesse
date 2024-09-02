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
            Image(systemName: "star.fill") // Utilisation d'une icône SF Symbol pour un remplissage étoilé
                .foregroundColor(.yellow) // Optionnel : mettez la couleur de l'étoile en jaune
        } else {
            Image(systemName: "star") // Utilisation d'une icône SF Symbol pour une étoile vide
                .foregroundColor(.gray) // Optionnel : mettez la couleur de l'étoile en gris
        }
    }
}

#Preview {
    IsFavoriteView(isFavorite: true)
}
