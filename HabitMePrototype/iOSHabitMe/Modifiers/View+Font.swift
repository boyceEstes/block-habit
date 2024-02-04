//
//  View+Font.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI



extension Font {
    
    static var sectionTitle: Font { .callout }
    static var navTitle: Font { .title2 }
}


#Preview {
    NavigationStack {
        VStack {
            Text("Section title font")
                .font(.sectionTitle)
                .sectionBackground()
        }
        
        Text("Sheety title font")
            .font(.navTitle)
    }
}
