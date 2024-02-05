//
//  EditHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI
import SwiftData


enum EditHabitAlert {
    case unsavedChangesWarning(yesAction: () -> Void)
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .unsavedChangesWarning(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Unsaved Changes",
                message: "You're leaving without saving the changes you made! Are you sure that you want to do this?",
                destroyTitle: "Confirm",
                destroyAction: yesAction
            )
        }
    }
}


struct EditHabitView: View {
    
    @Environment(\.dismiss) var dismiss

    @State private var alertDetail: AlertDetail?
    @State private var showAlert: Bool = false
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    
    @State private var selectedDetails: [DataActivityDetail]
    
    
    let habit: DataHabit
    let goToAddDetailsSelection: (Binding<[DataActivityDetail]>) -> Void
    
    
    init(
        habit: DataHabit,
        goToAddDetailsSelection: @escaping (Binding<[DataActivityDetail]>) -> Void
    ) {
        self.habit = habit
        self.goToAddDetailsSelection = goToAddDetailsSelection
        
        self._selectedDetails = State(initialValue: habit.activityDetails)
    }
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
                
                CreateHabitDetailContent(
                    goToAddDetailsSelection: goToAddDetailsSelection,
                    selectedDetails: $selectedDetails
                )
                
//                HabitMePrimaryButton(title: "Save", action: didTapSaveAndExit)
//                    .padding()
            }
        }
        .createEditHabitSheetPresentation()
        .onAppear {
            self.nameTextFieldValue = habit.name
            self.selectedColor = Color(hex: habit.color) ?? .gray
        }
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        
        .topBar {
            Text("Edit Habit")
        } topBarTrailingContent: {
            HabitMeSheetDismissButton(dismiss: resetAndExit)
        }
        
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HabitMePrimaryButton(
                    title: "Save",
                    isAbleToTap: isAbleToCreate,
                    action: didTapSaveAndExit
                )
                .padding()
            }
        }
    }
    
    
    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    private func didTapSaveAndExit() {
        
        updateHabitName()
        updateHabitColor()
        updateHabitDetails()
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
    
    
    private func updateHabitDetails() {
        
        print("update habit details")
        habit.activityDetails = selectedDetails
    }
    
    
    private func resetAndExit() {
        
        // We shouldn't have any changes at this point since we only save if we hit the save button.
        // Check if there are any changes that were made and if there were, pop a warning
        if selectedColor?.toHexString() != habit.color || nameTextFieldValue != habit.name {
            print("Exiting but making a change")
            alertDetail = EditHabitAlert.unsavedChangesWarning(yesAction: {
                dismiss()
            }).alertData()
            showAlert = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugging Dew",
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    
    return NavigationStack {
        EditHabitView(habit: dataHabit, goToAddDetailsSelection: { _ in })
    }
}
