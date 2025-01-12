//
//  EditHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW


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
    
    @EnvironmentObject var habitController: HabitController
    @Environment(\.dismiss) var dismiss
    
    // MARK: Injected Properties
    let habit: Habit
    let blockHabitStore: CoreDataBlockHabitStore
    let goToAddDetailsSelection: (Binding<[ActivityDetail]>, Color?) -> Void
    let goToScheduleSelection: (Binding<ScheduleTimeUnit>, Binding<Int>, Binding<Set<ScheduleDay>>, Binding<Date?>) -> Void
    // MARK: View Properties
    @State private var selectedDetails: [ActivityDetail]
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    @State private var completionGoal: Int? = nil
    // Scheduling
    @State private var schedulingUnits: ScheduleTimeUnit = .weekly // "Frequency" in Reminders app
    @State private var rate: Int = 1 // "Every" in Reminders App
    @State private var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @State private var reminderTime: Date? = nil // If it is not nil then a reminder has been set, else no reminder for
    // Alerts
    @State private var alertDetail: AlertDetail?
    @State private var showAlert: Bool = false
    
    
    init(
        habit: Habit,
        blockHabitStore: CoreDataBlockHabitStore,
        goToAddDetailsSelection: @escaping (Binding<[ActivityDetail]>, Color?) -> Void,
        goToScheduleSelection: @escaping (Binding<ScheduleTimeUnit>, Binding<Int>, Binding<Set<ScheduleDay>>, Binding<Date?>) -> Void
    ) {
        self.habit = habit
        self.blockHabitStore = blockHabitStore
        self.goToAddDetailsSelection = goToAddDetailsSelection
        self.goToScheduleSelection = goToScheduleSelection
        
        // FIXME: When `Habit` has `activityDetails` initialize this like expected
        self._selectedDetails = State(initialValue: habit.activityDetails.bjSort())
        self._completionGoal = State(initialValue: habit.goalCompletionsPerDay)
        
        self._schedulingUnits = State(initialValue: habit.schedulingUnits)
        self._rate = State(initialValue: habit.rate)
        self._scheduledWeekDays = State(initialValue: habit.scheduledWeekDays)
        self._reminderTime = State(initialValue: habit.reminderTime)
    }
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                CreateEditHabitContent(
                    nameTextFieldValue: $nameTextFieldValue,
                    selectedColor: $selectedColor
                )
                
                CreateEditHabitDetailContent(
                    goToAddDetailsSelection: goToAddDetailsSelection,
                    selectedDetails: $selectedDetails,
                    selectedColor: selectedColor
                )
                
                SchedulingContent(
                    schedulingUnits: $schedulingUnits,
                    rate: $rate,
                    scheduledWeekDays: $scheduledWeekDays,
                    reminderTime: $reminderTime,
                    goToScheduleSelection: goToScheduleSelection
                )
                
                CreateEditActivityCompletionGoalContent(
                    completionGoal: $completionGoal
                )
                
                Spacer()
                
                HabitMePrimaryButton(
                    title: "Save",
                    isAbleToTap: isAbleToCreate,
                    action: didTapSaveAndExit
                )
                .padding(.horizontal)
            }
        }
        .createEditHabitSheetPresentation()
        .onAppear {
            self.nameTextFieldValue = habit.name
            self.selectedColor = Color(hex: habit.color) ?? .gray
        }
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .sheetyTopBarNav(title: "Edit Activity", dismissAction: resetAndExit)
    }
    
    
    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    private func didTapSaveAndExit() {
        
        updateHabit()
        dismiss()
    }
    
    
    private func updateHabit() {
        
        print("HEY! ScheduledweekDay count: \(scheduledWeekDays.count)")
        
        
        guard let selectedColor, let selectedColorString = selectedColor.toHexString() else {
            // FIXME: Handle color not being set correctly error
            return
        }

        let habit = Habit(
            id: habit.id,
            name: nameTextFieldValue,
            creationDate: habit.creationDate,
            isArchived: habit.isArchived,
            goalCompletionsPerDay: completionGoal,
            color: selectedColorString,
            activityDetails: Set(selectedDetails),
            schedulingUnits: schedulingUnits,
            rate: rate,
            scheduledWeekDays: scheduledWeekDays,
            reminderTime: reminderTime
        )
        
        habitController.updateHabit(habit)
//        Task {
//            do {
//                let habitID = habit.id
//                
//                guard let selectedColor, let selectedColorString = selectedColor.toHexString() else {
//                    // FIXME: Handle color not being set correctly error
//                    return
//                }
//                
//                let habit = Habit(
//                    id: habitID,
//                    name: nameTextFieldValue,
//                    isArchived: habit.isArchived,
//                    goalCompletionsPerDay: completionGoal,
//                    color: selectedColorString,
//                    activityDetails: selectedDetails
//                )
//                
//                try await blockHabitStore.update(habitID: habitID, with: habit)
//            } catch {
//                // FIXME: Handle error updating!
//                fatalError("I GOT 99 PROBLEMS AND THIS IS 1 - \(error)")
//            }
//        }
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
    
    let habit = Habit.mopTheCarpet
    
    return NavigationStack {
        EditHabitView(habit: habit, blockHabitStore: CoreDataBlockHabitStore.preview(), goToAddDetailsSelection: { _, _ in }, goToScheduleSelection: { _, _, _, _ in })
    }
}
