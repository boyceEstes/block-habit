//
//  IsCompletedHabit.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation



public struct IsCompletedHabit: Hashable {
    
    public let habit: Habit
    public var status: HabitState
    
    
    public init(habit: Habit, status: HabitState) {
        self.habit = habit
        self.status = status
    }
    
    
    public var isCompleted: Bool {
        return status == .complete
    }
    
    
    public func nextState() -> HabitState {
        
        let habitGoal = habit.goalCompletionsPerDay ?? 1
        // If this was more than 1 and it was incomplete, go to partially complete
        
        switch status {
        case .incomplete:
            if habitGoal > 1 {
                return .partiallyComplete(count: 1, goal: habitGoal)
            } else if habitGoal == 1 {
                return .complete
            } else {
                // habitGoal is 0, leave on incomplete forever
                return .incomplete
            }
            
        case let .partiallyComplete(count, goal):
            if count + 1 >= goal {
                return .complete
            } else {
                return .partiallyComplete(count: count + 1, goal: goal)
            }
            
        case .complete:
            // Even if there are multiple, if we are tapping a competed habit, it should loop back around.
            return .incomplete
        }
    }
    
    
    public func previousState() -> HabitState {
        
        let habitGoal = habit.goalCompletionsPerDay ?? 1
        // TODO: We need to make sure that we account for the infinite goals (is that zero or nil? - can't remember)
        
        switch status {
        case .incomplete:
            // Then the last had to be complete.
            return .complete
            
        case let .partiallyComplete(count, goal):
            // then the last had to be another partially complete or an incomplete
            if count - 1 == 0 {
                return .incomplete
            } else {
                return .partiallyComplete(count: count - 1, goal: goal)
            }
            
        case .complete:
            // Then the last had to be partially complete or an incomplete
            if habitGoal > 1 {
                // partially complete
                return .partiallyComplete(count: habitGoal - 1, goal: habitGoal)
            } else {
                return .incomplete
            }
        }
    }
}
