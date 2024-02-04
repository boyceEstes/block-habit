//
//  View+SectionBackground.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI


extension View {
    
    func sectionBackground() -> some View {
        
        modifier(SectionBackground())
    }
    
}


struct SectionBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}


#Preview {

    VStack {
        Text("Hello world")
            .sectionBackground()
        
        VStack {
            Text("Hello world")
                .sectionBackground()
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        
        
        VStack {
            VStack {
                Text("Hello world")
                    .padding()
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
            }
            .frame(maxWidth:.infinity)
            .sectionBackground()
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
