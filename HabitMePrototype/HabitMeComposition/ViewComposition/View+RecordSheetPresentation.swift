//
//  View+RecordSheetPresentation.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/17/24.
//

import SwiftUI


extension View {
    
    func recordSheetPresentation(activityDetailCount: Int) -> some View {
        
        modifier(
            RecordSheetPresentation(activityDetailCount: activityDetailCount)
        )
    }
}


struct RecordSheetPresentation: ViewModifier {
    
    let activityDetailCount: Int
    
    func body(content: Content) -> some View {
        
        content
            .presentationDetents(activityDetailCount > 3 ? [.large] : [.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.background)
    }
}
