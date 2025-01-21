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
}
