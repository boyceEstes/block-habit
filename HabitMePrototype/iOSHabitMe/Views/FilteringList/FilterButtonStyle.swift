//
//  FilterButtonStyle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI


extension View {
    
    func filterButtonStyle(color: Color, isSelected: Bool) -> some View {
        
        modifier(FilterButtonStyle(color: color, isSelected: isSelected))
    }
}


struct FilterButtonStyle: ViewModifier {
    
    let color: Color
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        
        content
            .padding(8)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color : .clear)
                    .stroke(isSelected ? Color.clear : color, lineWidth: 3)
            )
    }
}

