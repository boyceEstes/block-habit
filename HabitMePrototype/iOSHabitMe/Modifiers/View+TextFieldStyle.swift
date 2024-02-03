//
//  View+TextFieldStyle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import Combine


struct NumberTextField: View {
    
    let title: String
    @Binding var text: String
    let units: String?
    
    @Binding var workingText: String
    @FocusState var isActive: Bool
    
    init(
        _ title: String,
        text: Binding<String>,
        units: String? = nil
    ) {
        self.title = title
        self._text = text
        self.units = units
        
        self._workingText = Binding(get: {
            
            let unwrappedText = text.wrappedValue
            let sanitizedNumber = unwrappedText.isEmpty ? "0" : unwrappedText
            return sanitizedNumber
            
        }, set: { newWorkingText in
            let sanitizedNumber = newWorkingText.isEmpty ? "0" : newWorkingText
            text.wrappedValue = String(sanitizedNumber)
        })
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            TextField(title, text: $workingText)
                .basicTextFieldStyle()
                .fixedSize(horizontal: true, vertical: false)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($isActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isActive = false
                        }
                    }
                }
                if let units {
                    Text("\(units)")
                        .font(.footnote)
                }
        }
    }
}

struct MultiLinerTextField: View {
    
    let title: String
    @Binding var text: String
    let lineLimit: ClosedRange<Int>
    
    init(_ title: String, text: Binding<String>, lineLimit: ClosedRange<Int> = 2...4) {
        
        self.title = title
        self._text = text
        self.lineLimit = lineLimit
    }
    
    
    var body: some View {
        
        TextField(title, text: $text, axis: .vertical)
            .multiLinerTextFieldStyle(numberOfLines: lineLimit)
    }
}


extension View {
    
    func basicTextFieldStyle() -> some View {
        textFieldStyle(BasicTextFieldStyle())
    }
    
    
    func multiLinerTextFieldStyle(numberOfLines: ClosedRange<Int> = 2...4) -> some View {
        textFieldStyle(MultiLinerTextFieldStyle(numberOfLines: numberOfLines))
    }
}


struct BasicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(10)
        .background(
            Color(uiColor: .tertiarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }
}


struct MultiLinerTextFieldStyle: TextFieldStyle {
    
    let numberOfLines: ClosedRange<Int>
    
    init(numberOfLines: ClosedRange<Int> = 2...4) {
        self.numberOfLines = numberOfLines
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .basicTextFieldStyle()
            .lineLimit(numberOfLines)
    }
}


#Preview {
    
    @State var someTextFieldValue = ""
    return VStack {
        VStack {
            Text("Basic")
            TextField("Description", text: $someTextFieldValue)
                .basicTextFieldStyle()
        }
        VStack {
            Text("MultiLiner (without custom TF)")
            TextField("Description", text: $someTextFieldValue)
                .multiLinerTextFieldStyle()
        }
        VStack {
            Text("MultiLiner")
            MultiLinerTextField("Description", text: $someTextFieldValue)
        }
        VStack {
            Text("NumberTextField")
            NumberTextField("Duration", text: $someTextFieldValue, units: "min")
        }
    }
}
