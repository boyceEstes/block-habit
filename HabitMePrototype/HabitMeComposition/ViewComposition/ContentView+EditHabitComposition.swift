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
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateEditHabit
        )
        .flowNavigationDestination(flowPath: $createEditHabitNavigationFlowPath) { identifier in
            switch identifier {
            case let .detailSelection(selectedDetails, selectedColor):
                makeAddDetailsViewWithSheetyNavigation(selectedDetails: selectedDetails, selectedColor: selectedColor)
            }
        }
    }
}
