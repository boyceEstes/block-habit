//
//  View+Font.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI



extension Font {
    
    static var sectionTitle: Font { .callout }
    
    
    
    // Specific
    static var navTitle: Font { .title2 }
    static var navSubtitle: Font { .subheadline }
    
    static var rowTitle: Font { .headline }
    static var rowDetail: Font { .callout }
}


#Preview {
//    NavigationStack {
        VStack {
            Text("Section title font")
                .font(.sectionTitle)
            
            Text("Sheety title font")
                .font(.navTitle)
            
            Text("Sheety subtitle font")
                .font(.navSubtitle)
            
            Text("Row title font")
                .font(.rowTitle)
        }
        .preferredColorScheme(.light)
        .previewLayout(.sizeThatFits)
//    }
    
}
