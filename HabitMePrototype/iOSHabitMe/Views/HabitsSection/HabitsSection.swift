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
        
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Text("Habits")
                    Spacer()
                    Button(action: goToCreateHabit) {
                        Image(systemName: "plus.circle")
                    }
                }
                .homeDetailTitle()
                
                HStack {
                    HStack(spacing: 4) {
                        Text("Daily Goal")
                        Text("\(completedNumberOfHabitsOnSelectedDay)/\(goalNumberOfHabitCompletionsOnSelectedDay) ⛳️")
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Streak")
                        Text("\(currentStreak) 🔥")
                            .foregroundStyle(.primary)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
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
    
    
    // MARK: Helper Logic
    
    
    // FIXME: Reevaluate when it is ready to consider scheduling habits for...
    // ...specific days
    //
    // Not considering specific days is also a problem, because we not get an accurate
    // goal whenever you are going back in time to a different day
    //
    // A good way to fix this would be to make a new property called `createdDate` on
    // the Habit. And we could detect whether or not the habit was made on that same day
    // and only then would we include it?
    //
    // Then also have the days that we want to display this habit for... This one will be
    // more complicated
    
    
    /**
     * The Daily Goal will be based on the number of habit records that you
     * need to create for a given day. This means that you will need to
     * account for the completionGoal of each habit.
     *
     * **NOTE**: This does not include tasks with no completion goal
     */
    var goalNumberOfHabitCompletionsOnSelectedDay: Int {
        
        habitController.isCompletedHabits
            .reduce(0) { partialResult, isCompletedHabit in
                
                guard let completionGoal = isCompletedHabit.habit.goalCompletionsPerDay else {
                    
                    // Do not include any habits without a completion goal in the count
                    return partialResult
                }
                
                guard let habitCreationDateAtNoon = isCompletedHabit.habit.creationDate.noon,
                      habitController.selectedDay <= habitCreationDateAtNoon else {
                    // Do not include any habits without a completion goal in the count
                    return partialResult
                }

                
                return partialResult + completionGoal
            }
    }
    
    
    // FIXME: There is bit of an edge-case here if the user were to change their completion goals later it will show an inaccurate number
    /**
     * This number is calculated based on the number of records for the day.. Its occurring to me now that
     * this number could change if we were to change the completionGoal number later....
     *
     */
    var completedNumberOfHabitsOnSelectedDay: Int {
        habitController.habitRecordsForSelectedDay
            .reduce(0) { partialResult, habitRecord in
                guard habitRecord.habit.goalCompletionsPerDay != nil else {
                    // Do not include any habit records of habits with no completion goal in the count
                    return partialResult
                }
                
                // For each record, add 1
                return partialResult + 1
            }
    }
    
    
    /// Assuming today is the last day in habitsRecordsForDays
    var currentStreak: Int {
        
        StatisticsCalculator.findCurrentUsageStreak(for: habitController.habitRecordsForDays)
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
