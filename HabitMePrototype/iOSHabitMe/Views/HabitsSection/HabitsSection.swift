//
//  HabitsSection.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI
import HabitRepositoryFW


struct HabitsSection: View {
    
    // Would prefer dependency injection accessing environmentObject everywhere
    // MARK: Injected Logic
    let habitController: HabitController
    // Navigation
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    let goToCreateHabit: () -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    
    var body: some View {
        
        
        HabitsMenu(
            completedHabits: habitController.completeHabits,
            incompletedHabits: habitController.incompleteHabits,
            goToHabitDetail: goToHabitDetail,
            goToEditHabit: goToEditHabit,
            didTapCreateHabitButton: {
                goToCreateHabit()
            }, didTapHabitButton: { habit in
                //                         FIXME: 2 - viewModel.createHabitRecord(for: habit)
                habitController.createRecordOrNavigateToRecordWithDetails(
                    for: habit,
                    goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                )
            }, archiveHabit: { habit in
                
                habitController.archiveHabit(habit)
            }
        )
    }
}



#Preview {
    
    
    HabitsSection(
        habitController: HabitController(
            blockHabitRepository: CoreDataBlockHabitStore.preview(),
            selectedDay: Date()
        ),
        goToHabitDetail: { _ in },
        goToEditHabit: { _ in },
        goToCreateHabit: { },
        goToCreateActivityRecordWithDetails: { _, _ in }
    )
}
