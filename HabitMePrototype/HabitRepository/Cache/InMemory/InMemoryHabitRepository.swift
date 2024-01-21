//
//  InMemoryHabitRepository.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import Foundation


class InMemoryHabitRepository: HabitRepository {
    
    // We'll init it with some demo data
    private var habits = Habit.habits
    private var habitRecords = HabitRecord.habitRecords {
        didSet {
            print("Updated habit records...")
            print(habitRecords)
        }
    }
    
    
    func fetchAllHabitRecords(completion: (FetchAllHabitRecordsResult) -> Void) {
        
        print("fetching... \(habitRecords.count)")
        completion(habitRecords)
    }
    
    
    func insertNewHabitRecord(_ habitRecord: HabitRecord, completion: (InsertResult) -> Void) {
        
        print("Adding Habit Record: \(habitRecord.habit.name) ")
        habitRecords.append(habitRecord)
        
        completion(nil)
    }
    
    
    func fetchAllHabits(completion: (FetchAllHabitsResult) -> Void) {
        
        completion(habits)
    }
    
    
    func insertNewHabit(habit: Habit, completion: (InsertResult) -> Void) {
        habits.append(habit)
        completion(nil)
    }
}
