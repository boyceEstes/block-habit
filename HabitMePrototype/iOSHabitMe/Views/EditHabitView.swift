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
    
    @State private var selectedDetails: [ActivityDetail]
    
    
    let habit: Habit
    let blockHabitStore: CoreDataBlockHabitStore
    let goToAddDetailsSelection: (Binding<[ActivityDetail]>, Color?) -> Void
    
    
    init(
        habit: Habit,
        blockHabitStore: CoreDataBlockHabitStore,
        goToAddDetailsSelection: @escaping (Binding<[ActivityDetail]>, Color?) -> Void
    ) {
        self.habit = habit
        self.blockHabitStore = blockHabitStore
        self.goToAddDetailsSelection = goToAddDetailsSelection
        
        // FIXME: When `Habit` has `activityDetails` initialize this like expected
        self._selectedDetails = State(initialValue: habit.activityDetails)
    }
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
                
                CreateHabitDetailContent(
                    goToAddDetailsSelection: goToAddDetailsSelection,
                    selectedDetails: $selectedDetails,
                    selectedColor: selectedColor
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
        
        .sheetyTopBarNav(title: "Edit Activity", dismissAction: resetAndExit)
        .sheetyBottomBarButton(title: "Save", isAbleToTap: isAbleToCreate, action: didTapSaveAndExit)
    }
    
    
    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    private func didTapSaveAndExit() {
        
        // FIXME: Save `Habit` updates
//        updateHabitName()
//        updateHabitColor()
//        updateHabitDetails()
        updateHabit()
        dismiss()
    }
    
    
    private func updateHabit() {
        
        Task {
            do {
                let habitID = habit.id
                
                guard let selectedColor, let selectedColorString = selectedColor.toHexString() else {
                    // FIXME: Handle color not being set correctly error
                    return
                }
                
                let habit = Habit(
                    id: habitID,
                    name: nameTextFieldValue,
                    color: selectedColorString,
                    activityDetails: selectedDetails
                )
                
                try await blockHabitStore.update(habitID: habitID, with: habit)
            } catch {
                // FIXME: Handle error updating!
                fatalError("I GOT 99 PROBLEMS AND THIS IS 1 - \(error)")
            }
        }
    }
    
    
    private func updateHabitName() {
        
        print("update habit name")
//        habit.name = nameTextFieldValue
    }
    
    
    private func updateHabitColor() {
        
        guard let selectedColor, let selectedColorString = selectedColor.toHexString() else { return }
        
        print("update habit color")
//        habit.color = selectedColorString
    }
    
    
    private func updateHabitDetails() {
        
        print("update habit details")
//        habit.activityDetails = selectedDetails
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


public extension Habit {
    
    static let preview = Habit(
        id: UUID().uuidString,
        name: "Chugging Dew",
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        activityDetails: []
    )
}


#Preview {
    
    // FIXME: Remove the below unnecessary preview code
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugging Dew",
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    
    
    let habit = Habit.preview
    
    return NavigationStack {
        EditHabitView(habit: habit, blockHabitStore: CoreDataBlockHabitStore.preview(), goToAddDetailsSelection: { _, _ in })
    }
}
