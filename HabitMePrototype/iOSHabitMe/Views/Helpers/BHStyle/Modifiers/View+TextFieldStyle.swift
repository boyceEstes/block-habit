//
//  View+TextFieldStyle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import Combine



extension View {
    
    func textFieldBackground(color: Color = .secondaryBackground) -> some View {
        
        modifier(TextFieldBackground(color: color))
    }
}


struct TextFieldBackground: ViewModifier {
    
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .sectionBackground(padding: .detailPadding, color: color)
    }
}


#Preview {
    
    @Previewable @State var someTextFieldValue = ""
    return VStack {
        VStack {
            Text("Basic")
            TextField("Description", text: $someTextFieldValue)
                .textFieldBackground()
        }
    }
}
