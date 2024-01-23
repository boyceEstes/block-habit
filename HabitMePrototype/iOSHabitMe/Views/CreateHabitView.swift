//
//  CreateHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI





struct CreateHabitView: View {
    
    let habitRepository: HabitRepository
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    
    let allColors = [
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
    
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Create New Habit")
                    .font(.title2)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .font(.title2)
                }
            }
            .padding()
            .padding(.top)
            
            TextField("Name", text: $nameTextFieldValue)
                .font(.headline)
                .textFieldStyle(MyTextFieldStyle())
            
            VStack {
                LazyHGrid(rows: rows, spacing: 30) {
                    ForEach(allColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                if selectedColor == color {
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
            .background(Color(uiColor: .darkGray))
            .clipShape(
                RoundedRectangle(cornerRadius: 10))
            .padding()
            
            
            Button("Create Habit") {
                
                guard let selectedColor, let stringColorHex = selectedColor.toHexString() else {
                    return
                }
//                let newHabit = Habit(name: nameTextFieldValue, color: selectedColor)
                

                let newDataHabit = DataHabit(name: nameTextFieldValue, color: stringColorHex, habitRecords: [])
                
                modelContext.insert(newDataHabit)
//                habitRepository.insertNewHabit(habit: newHabit) { error in
//                    if let error {
//                        fatalError("There was an issue \(error.localizedDescription)")
//                    }
//                    print("Insert new habit")
                    DispatchQueue.main.async {
                        dismiss()
                    }
//                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isAbleToCreate ? Color.blue : Color.blue.opacity(0.5))
            .foregroundStyle(isAbleToCreate ? Color.white : Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            .disabled(isAbleToCreate == true ? false : true)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
    }
    
    
    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
}
