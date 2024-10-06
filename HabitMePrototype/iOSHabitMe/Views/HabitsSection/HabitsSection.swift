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
    // MARK: View Properties
    @ScaledMetric(relativeTo: .body) var scaledDayTitleWidth: CGFloat = 150
    
    var body: some View {
        
        VStack(spacing: 0) {
                HStack {
                    
                    HStack {
                        Button {
                            habitController.goToPrevDay()
                        } label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                        }
                        // FIXME: 2 See more at the definition for that
                        .disabled(habitController.isAllowedToGoToPrevDay() ? false : true)
                        
                        Spacer()
                        
                        Text(habitController.selectedDay.displayDate)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            habitController.goToNextDay()
                        } label: {
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                        }
                        .disabled(habitController.isAllowedToGoToNextDay() ? false : true)
                    }
                    .frame(maxWidth: scaledDayTitleWidth)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    
                    Spacer()
                    
                    Button(action: goToCreateHabit) {
                        Image(systemName: "plus.circle")
                    }
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .homeDetailTitle()
            .padding(.horizontal)
            .padding(.vertical)
            
            
            HabitsMenu(
                completedHabits: habitController.completeHabits,
                incompletedHabits: habitController.incompleteHabits,
                goToHabitDetail: goToHabitDetail,
                goToEditHabit: goToEditHabit,
                didTapHabitButton: { habit in
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
        .background(Color.secondaryBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 20))
        .padding()
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
