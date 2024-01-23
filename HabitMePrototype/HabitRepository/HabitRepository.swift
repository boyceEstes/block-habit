//
//  HabitRepository.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import Foundation

protocol HabitRepository {
    
    typealias FetchAllHabitRecordsResult = [HabitRecord]
    typealias FetchAllHabitsResult = [Habit]
    typealias InsertResult = SpecialHabitError?
    
    func fetchAllHabitRecords(completion: (FetchAllHabitRecordsResult) -> Void)
    func insertNewHabitRecord(_ habitRecord: HabitRecord, completion: (InsertResult) -> Void)
    func fetchAllHabits(completion: (FetchAllHabitsResult) -> Void)
    func insertNewHabit(habit: Habit, completion: (InsertResult) -> Void)
}


