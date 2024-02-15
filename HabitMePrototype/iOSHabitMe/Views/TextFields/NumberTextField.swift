//
//  NumberTextField.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import SwiftUI


struct NumberTextFieldRow: View {
    
    let title: String
    @Binding var text: String
    let units: String?
    var focused: FocusState<Focusable?>.Binding
    var focusID: Int
    
    var body: some View {
        
        HStack {
            
            Text(title)
                .font(.rowDetail)
            
            Spacer()
            
            NumberTextField(
                title,
                text: $text,
                units: units,
                focused: focused,
                focusID: focusID
            )
            
        }
        .sectionBackground(padding: .detailPadding)
    }
}


struct NumberTextField: View {
    
    let title: String
    @Binding var text: String
    let units: String?
    var focused: FocusState<Focusable?>.Binding
    var focusID: Int
    
    /// Initialized with a binding from the binding `text` that was passed in - this is to make it format correctly when a 0 or nothing is typed
    @Binding var workingText: String
    
    init(
        _ title: String,
        text: Binding<String>,
        units: String? = nil,
        focused: FocusState<Focusable?>.Binding,
        focusID: Int
    ) {
        self.title = title
        self._text = text
        self.units = units
        self.focused = focused
        self.focusID = focusID
        
        self._workingText = Binding(get: {
            
            let unwrappedText = text.wrappedValue
            let sanitizedNumber = unwrappedText.isEmpty ? "" : unwrappedText
            return sanitizedNumber
            
        }, set: { newValue in
            text.wrappedValue = newValue
        })
    }
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            TextField("0", text: $workingText)
                .multilineTextAlignment(units != nil ? .trailing : .center)
                .keyboardType(.numberPad)
                .frame(width: 60)
                .focused(focused, equals: .row(id: focusID))
            if let units {
                Text("\(units)")
                    .lineLimit(1)
                    .font(.footnote)
                //                    .frame(width: 40)
                // TODO: scale up with dynamic type
            }
        }
        .textFieldBackground(color: .tertiaryBackground)
        .contentShape(Rectangle())
    }
}


#Preview {
    
    @State var someTextFieldValue = ""
    @FocusState var previewFocused: Focusable?
    return VStack {
        
        NumberTextFieldRow(
            title: "Things",
            text: $someTextFieldValue,
            units: "stuffs",
            focused: $previewFocused,
            focusID: 0
        )
        
        VStack {
            Text("NumberTextField with units")
            NumberTextField(
                "Duration",
                text: $someTextFieldValue,
                units: "minutes really long",
                focused: $previewFocused,
                focusID: 0
            )
        }
        VStack {
            Text("NumberTextField without units")
            NumberTextField(
                "Duration",
                text: $someTextFieldValue,
                focused: $previewFocused,
                focusID: 0
            )
        }
    }
}
