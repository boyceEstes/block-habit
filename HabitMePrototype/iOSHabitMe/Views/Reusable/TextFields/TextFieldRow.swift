//
//  TextFieldRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/14/24.
//

import SwiftUI

struct TextFieldRow: View {
    
    let title: String
    @Binding var text: String
    let isExpandable = true
    
    var focused: FocusState<Focusable?>.Binding
    var focusID: Int
    
    var body: some View {
        
        if isExpandable {
            TextField(
                title,
                text: $text,
                axis: .vertical
            )
            .focused(focused, equals: .row(id: focusID))
            .textFieldBackground()
        } else {
            TextField(
                title,
                text: $text,
                axis: .vertical
            )
            .focused(focused, equals: .row(id: focusID))
            .textFieldBackground()
        }
    }
}

#Preview {
    
    @Previewable @State var someTextFieldValue = ""
    @FocusState var previewFocused: Focusable?
    
    return VStack {
        TextFieldRow(
            title: "Texty mesty",
            text: $someTextFieldValue,
            focused: $previewFocused,
            focusID: 0
        )
    }
}
