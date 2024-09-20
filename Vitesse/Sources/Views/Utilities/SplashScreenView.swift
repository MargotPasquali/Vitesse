//
//  Splash Screen.swift
//  Vitesse
//
//  Created by Margot Pasquali on 16/09/2024.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var textOffset: CGFloat = 300 // Initial offset for the text (out of view)

    var body: some View {
        ZStack {
            VStack {
                Spacer() // Espace flexible au-dessus du logo

                // Logo centré
                Image("Logo Vitesse")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400) // Ajustez la taille maximale si nécessaire

                // Texte superposé pour l'effet d'ombre avec animation sur le HStack
                HStack {
                    Spacer()
                    // Texte d'ombre (gris clair) avec un léger décalage
                    Text("Recrutement")
                        .font(Font.custom("Allura-Regular", size: 40))
                        .foregroundColor(Color(hex: "D3D3D3"))
                        .offset(x: 170, y: 3) // Légère décalage pour l'effet d'ombre

                    // Texte principal (noir) superposé au-dessus
                    Text("Recrutement")
                        .font(Font.custom("Allura-Regular", size: 40))
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .offset(y: -35) // Remonter la HStack avec un offset négatif
                .offset(x: textOffset) // Animation sur la position horizontale du HStack
                .onAppear {
                    // Animation déclenchée à l'apparition de la vue
                    withAnimation(.easeInOut(duration: 2)) {
                        textOffset = 0 // Ramène les textes à leur position initiale
                    }
                }

                Spacer() // Espace flexible sous le texte
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
