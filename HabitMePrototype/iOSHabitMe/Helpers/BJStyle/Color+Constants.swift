//
//  Color+Constants.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import SwiftUI

extension Color {
    
    static let primaryBackground: Color = Color(uiColor: .secondarySystemGroupedBackground)
    static let secondaryBackground: Color = Color(uiColor: .tertiarySystemGroupedBackground)
    // tertiaryBackground color that I have in Assets because it is more custom
    
    static let secondaryFont: Color = .secondary
}


#Preview {

    VStack {
        VStack {
            Text("Some kind of text")
                .foregroundStyle(.secondary)
            Text("Some kind of text")
                .foregroundStyle(Color.secondaryFont)
        }
        .sectionBackground()
        
        VStack {
            Text("In secondary background")
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.tertiaryBackground, in: RoundedRectangle(cornerRadius: 10))
            Text("In secondary background")
                .foregroundStyle(Color.secondaryFont)
                .padding()
                .background(Color.tertiaryBackground, in: RoundedRectangle(cornerRadius: 10))
        }
        .sectionBackground()
        
        VStack {
            Text("In tertiary background")
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.tertiaryBackground, in: RoundedRectangle(cornerRadius: 10))
            Text("In tertiary background")
                .foregroundStyle(Color.secondaryFont)
                .padding()
                .background(Color.tertiaryBackground, in: RoundedRectangle(cornerRadius: 10))
        }
        .sectionBackground()
        
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.primaryBackground)
}
