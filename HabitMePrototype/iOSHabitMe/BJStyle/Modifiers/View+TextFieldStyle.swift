//
//  View+TextFieldStyle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import Combine


extension View {
    
    func textFieldBackground() -> some View {
        
        modifier(TextFieldBackground())
    }
}


struct TextFieldBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.textFieldPadding)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: .cornerRadius))
    }
}


#Preview {
    
    @State var someTextFieldValue = ""
    return VStack {
        VStack {
            Text("Basic")
            TextField("Description", text: $someTextFieldValue)
                .textFieldBackground()
        }
    }
}
