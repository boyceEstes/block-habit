//
//  CreateHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


extension View {
    
    func createEditHabitSheetPresentation() -> some View {
        modifier(CreateEditHabitSheetPresentation())
    }
}

struct CreateEditHabitSheetPresentation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.background)
    }
}


struct CreateHabitView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    

    
    var body: some View {
        VStack(spacing: 0) {
            SheetTitleBar(title: "Create New Habit") {
                HabitMeSheetDismissButton(dismiss: { dismiss() })
            }
            
            Spacer()
            
            CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
            
            Spacer()
            
            HabitMePrimaryButton(title: "Create Habit", isAbleToTap: isAbleToCreate, action: didTapButtonToCreateHabit)
                .padding()
            
        }
//        .frame(height: 400)
        .createEditHabitSheetPresentation()
    }
    
    
    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    func didTapButtonToCreateHabit() {
        
        guard let selectedColor, let stringColorHex = selectedColor.toHexString() else {
            return
        }

        let newDataHabit = DataHabit(name: nameTextFieldValue, color: stringColorHex, habitRecords: [])
        
        modelContext.insert(newDataHabit)
        DispatchQueue.main.async {
            dismiss()
        }
    }
}


struct CreateEditHabitContent: View {
    
    
    @Binding var nameTextFieldValue: String
    @Binding var selectedColor: Color?
    
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        TextField("Name", text: $nameTextFieldValue)
            .font(.headline)
            .textFieldStyle(MyTextFieldStyle())
        
        VStack {
            LazyHGrid(rows: rows, spacing: 30) {
                ForEach(allColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .stroke(Color.white, lineWidth: isColorSelected(color) ? 2 : 0)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            if isColorSelected(color) {
                                selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }
                }
            }
            .frame(height: 90)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    
    func isColorSelected(_ color: Color) -> Bool {
        
        selectedColor?.toHexString() == color.toHexString()
    }
    
    
    var allColors: [Color] {
        [
            Color.red,
            Color.orange,
            Color.yellow,
            Color.green,
            Color.mint,
            Color.teal,
            
            Color.cyan,
            Color.blue,
            Color.indigo,
            Color.purple,
            Color.pink,
            Color.brown
        ]
    }
}



struct SheetTitleBar<TitleButtonContent: View>: View {
    
    let title: String
    let subtitle: String?
    @ViewBuilder var titleButtonContent: () -> TitleButtonContent
    
    
    init(title: String, subtitle: String? = nil, titleButtonContent: @escaping () -> TitleButtonContent) {
        self.title = title
        self.subtitle = subtitle
        self.titleButtonContent = titleButtonContent
    }
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                if let subtitle {
                    Text("\(subtitle)")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
            Spacer()
            
            titleButtonContent()

        }
        .padding(.horizontal)
        .padding(.top)
    }
}


struct HabitMeSheetDismissButton: View {
    
    let dismiss: () -> Void
    
    var body: some View {
        
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.title)
        }
    }
}


struct FunButtonPressStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct HabitMePrimaryButton: View {
    
    let title: String
    let isAbleToTap: Bool
    let color: Color
    let buttonWidth: CGFloat?
    let action: () -> Void
    
    init(title: String, isAbleToTap: Bool = true, color: Color? = nil, buttonWidth: CGFloat? = nil, action: @escaping () -> Void) {
        
        self.title = title
        self.action = action
        self.color = color ?? .blue
        self.isAbleToTap = isAbleToTap
        self.buttonWidth = buttonWidth
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: buttonWidth ?? .infinity)
                .frame(height: 50)
                .background(isAbleToTap ? color : color.opacity(0.5))
                .foregroundStyle(isAbleToTap ? Color.white : Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                .disabled(isAbleToTap == true ? false : true)
        }
        .buttonStyle(FunButtonPressStyle())
    }
}


#Preview {
    
    CreateHabitView()
}
