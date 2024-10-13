//
//  IsCompletedHabit.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation



public struct IsCompletedHabit: Hashable {
    
    public let habit: Habit
    public var isCompleted: Bool
    
    
    public init(habit: Habit, isCompleted: Bool) {
        self.habit = habit
        self.isCompleted = isCompleted
    }
}
