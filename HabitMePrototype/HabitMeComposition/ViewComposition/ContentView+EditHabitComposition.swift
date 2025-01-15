//
//  ContentView+EditHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI
import HabitRepositoryFW


extension ContentView {
    
    @ViewBuilder
    func makeEditHabitView(habit: Habit) -> some View {
        
        EditHabitView(
            habit: habit,
            blockHabitStore: blockHabitStore,
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateEditHabit,
            goToScheduleSelection: goToSchedulingSelectionFromCreateEditHabit
        )
        .sheet(item: $createEditHabitNavigationFlowDisplayedSheet) { identifier in
            switch identifier {
            case let .detailSelection(selectedDetails, selectedColor):
                let _ = print("we're supposed to go here! I know it!")
                makeAddDetailsViewWithSheetyNavigation(selectedDetails: selectedDetails, selectedColor: selectedColor)
            }
        }
        .flowNavigationDestination(flowPath: $createEditHabitNavigationFlowPath) { identifier in
            switch identifier {
            case let .scheduleSelection(schedulingUnits, rate, scheduledWeekDays, reminderTime):
                makeScheduleView(schedulingUnits: schedulingUnits, rate: rate, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime)
            }
        }
    }
}
