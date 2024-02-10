//
//  View+SectionBackground.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI


extension View {
    
    func sectionBackground(color: Color = .secondaryBackground) -> some View {
        
        modifier(SectionBackground(color: color))
    }
    
}


struct SectionBackground: ViewModifier {
    
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(color, in: RoundedRectangle(cornerRadius: .cornerRadius))
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
