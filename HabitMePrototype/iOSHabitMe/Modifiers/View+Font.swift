//
//  View+Font.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI


extension View {
    
    func sectionTitleFont() -> some View {
        modifier(SectionTitleFont())
    }
}


struct SectionTitleFont: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.callout)
    }
}


#Preview {
    VStack {
        Text("Section title font")
            .sectionTitleFont()
            .sectionBackground()
    }
}
