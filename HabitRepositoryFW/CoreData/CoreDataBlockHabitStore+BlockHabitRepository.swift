//
//  CoreDataBlockHabitStore+BlockHabitRepository.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/4/24.
//

import Foundation


extension CoreDataBlockHabitStore: BlockHabitRepository {
    
    public func createHabit(_ habit: Habit) async throws {
        // TODO: later
    }
    
    public func readAllNonarchivedHabits() async throws -> [Habit] {
        // TODO: later
        []
    }
    
    public func updateHabit(id: String, with habit: Habit) async throws {
        // TODO: later
    }
    
    public func destroyHabit(_ habit: Habit) async throws {
        // TODO: later
    }
    
    public func createHabitRecord(_ habitRecord: HabitRecord) async throws {
        // TODO: later
    }
    
    public func readAllHabitRecords() async throws -> [HabitRecord] {
        // TODO: later
        []
    }
    
    public func updateHabitRecord(id: String, with habitRecord: HabitRecord) async throws {
        // TODO: later
    }
    
    public func destroyHabitRecord(_ habitRecord: HabitRecord) async throws {
        // TODO: later
    }
}
