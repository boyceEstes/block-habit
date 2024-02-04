//
//  View+TextFieldStyle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import Combine


struct Constant {
    
    static let textFieldPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 10
}


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
            
            let count = newWorkingText.count
            
            if count < 2 {
                text.wrappedValue = newWorkingText
            } else {
                text.wrappedValue = text.wrappedValue
            }
//            let sanitizedNumber = newWorkingText.isEmpty ? "0" : newWorkingText
//            text.wrappedValue = String(sanitizedNumber)
//            return sanitizedNumber
        })
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            TextField("0", text: $workingText)
                .multilineTextAlignment(units != nil ? .trailing : .center)
                .keyboardType(.numberPad)
                .focused($isActive)
                .frame(width: 60)
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
                    .lineLimit(1)
                    .font(.footnote)
                //                    .frame(width: 40)
                // TODO: scale up with dynamic type
            }
        }
        .textFieldBackground()
        .contentShape(Rectangle())
        .onTapGesture {
            isActive = true
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
        TextField(title, text: $text, prompt: Text(""), axis: .vertical)
            .lineLimit(lineLimit)
            .textFieldBackground()
    }
}



//struct BasicTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//        .padding(8)
//        .background(
//            Color(uiColor: .tertiarySystemGroupedBackground),
//            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
//        )
//    }
//}


extension View {
    
    func textFieldBackground() -> some View {
        
        modifier(TextFieldBackground())
    }
}


struct TextFieldBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(Constant.textFieldPadding)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Constant.cornerRadius))
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
        VStack {
            Text("MultiLiner")
            MultiLinerTextField("Description", text: $someTextFieldValue)
        }
        VStack {
            Text("NumberTextField with units")
            NumberTextField("Duration", text: $someTextFieldValue, units: "minutes really long")
        }
        VStack {
            Text("NumberTextField without units")
            NumberTextField("Duration", text: $someTextFieldValue)
        }
    }
}
