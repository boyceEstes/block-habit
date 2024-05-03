//
//  Array+IsCompletedHabits.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation



public extension Array where Element == Habit {
    
    func toIsCompleteHabits(recordsForSelectedDay: [HabitRecord]) -> Set<IsCompletedHabit> {
        
        var isCompletedHabits = Set<IsCompletedHabit>()
        
        for habit in self {
            
            guard !habit.isArchived else {
                continue // Do not add this to the list. It should Ideally not even be returned and never hit, but just in case
            }
            
            guard let completionGoal = habit.goalCompletionsPerDay,
                    completionGoal != 0 else {
                isCompletedHabits.insert(IsCompletedHabit(habit: habit, isCompleted: false))
                continue
            }
            
            let numOfRecordsForHabit = recordsForSelectedDay.filter { $0.habit.id == habit.id }.count
            
            isCompletedHabits.insert(IsCompletedHabit(habit: habit, isCompleted: numOfRecordsForHabit >= completionGoal))
        }
        return isCompletedHabits
    }
}
