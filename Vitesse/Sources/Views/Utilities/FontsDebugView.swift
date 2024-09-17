//
//  FontsDebugView.swift
//  Vitesse
//
//  Created by Margot Pasquali on 16/09/2024.
//

import SwiftUI

struct FontsDebugView: View {
    var body: some View {
        List {
            ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                Section(header: Text(family).font(.headline)) {
                    ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { fontName in
                        Text(fontName)
                            .font(Font.custom(fontName, size: 16))
                    }
                }
            }
        }
    }
}

#Preview {
    FontsDebugView()
}
