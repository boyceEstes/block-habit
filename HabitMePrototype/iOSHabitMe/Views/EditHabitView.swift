//
//  EditHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI
import SwiftData


//enum EditHabitAlert {
//    case deleteHabit(yesAction: () -> Void)
//    
//    func alertData() -> AlertDetail {
//        
//        switch self {
//        case let .deleteHabit(yesAction):
//            return AlertDetail.destructiveAlert(
//                title: "Are you sure?",
//                message: "This will delete all of the habit's associated records as well 👀",
//                destroyTitle: "Destroy It All",
//                destroyAction: yesAction
//            )
//        }
//    }
//}


struct EditHabitView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var alertDetail: AlertDetail?
    @State private var showAlert: Bool = false
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    
    let habit: DataHabit
    
    var body: some View {
        
        VStack {
            SheetTitleBar(title: "Edit Habit") {
                HStack {
                    HabitMeSheetDismissButton(dismiss: { dismiss() })
                }
            }
            
            CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
            
            
            HabitMePrimaryButton(title: "Save And Exit", action: didTapSaveAndExit)
                .padding()
            
            Spacer()
        }
        .createEditHabitSheetPresentation()
        .onAppear {
            self.nameTextFieldValue = habit.name
            self.selectedColor = Color(hex: habit.color) ?? .gray
        }
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
    }
    
    
    private func didTapSaveAndExit() {
        
        updateHabitName()
        updateHabitColor()
        dismiss()
    }
    
    
    private func updateHabitName() {
        
        print("update habit name")
        habit.name = nameTextFieldValue
    }
    
    
    private func updateHabitColor() {
        
        guard let selectedColor, let selectedColorString = selectedColor.toHexString() else { return }
        
        print("update habit color")
        habit.color = selectedColorString
    }
    
    
    private func resetAndExit() {
        
        // We shouldn't have any changes at this point since we only save if we hit the save button.
        // Check if there are any changes that were made and if there were, pop a warning
//        if selectedColor?.toHexString() != habit.color || nameTextFieldValue != habit.name {
//            
//        }
        dismiss()
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        id: UUID().uuidString,
        name: "Chugging Dew",
        color: Habit.habits.randomElement()?.color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    
    return EditHabitView(habit: dataHabit)
}
