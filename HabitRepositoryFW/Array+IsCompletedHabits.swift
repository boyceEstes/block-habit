//
//  Array+IsCompletedHabits.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation



public extension Array where Element == Habit {
    
    /// Call when setting in-memory habits for the day from the database. This could happen on launch or on switching the selected day
    func toIsCompleteHabits(recordsForSelectedDay: [HabitRecord]) -> Set<IsCompletedHabit> {
        
        var isCompletedHabits = Set<IsCompletedHabit>()
        
        for habit in self {
            
            guard !habit.isArchived else {
                continue // Do not add this to the list. It should Ideally not even be returned and never hit, but just in case
            }
            
            // FIXME: This will need to updated to account for habits that can never be completed so next state and prev state can be calculated correctly
            // if we have a completion goal thats zero or unavailable just return habit as incomplete.
            guard let completionGoal = habit.goalCompletionsPerDay,
                    completionGoal != 0 else {
                isCompletedHabits.insert(IsCompletedHabit(habit: habit, status: .incomplete))
                continue
            }
            
            
            let numOfRecordsForHabitForToday = recordsForSelectedDay.filter { $0.habit.id == habit.id }.count
            
            var isCompletedHabit = IsCompletedHabit(habit: habit, status: .incomplete)
            
            if numOfRecordsForHabitForToday == 0 {
                // There are no records for habit for today, keep as incomplete
                
            } else if numOfRecordsForHabitForToday > 0 {
                if numOfRecordsForHabitForToday >= numOfRecordsForHabitForToday {
                    isCompletedHabit.status = .complete
                } else {
                    isCompletedHabit.status = .partiallyComplete(count: numOfRecordsForHabitForToday, goal: completionGoal)
                }
            }
            
            
            isCompletedHabits.insert(isCompletedHabit)
        }
        return isCompletedHabits
    }
}
