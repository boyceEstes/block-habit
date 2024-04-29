//
//  CoreDataBlockHabitStore+Habit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/25/24.
//

import Foundation
import CoreData
import HabitRepositoryFW



extension NSManagedObjectContext {
    
    func fetchHabit(withID habitID: String) throws -> ManagedHabit {
        
        guard let managedHabit = try fetch(ManagedHabit.findHabitRequest(with: habitID)).first else {
            throw HabitRepositoryError.couldNotFindHabitWithID(id: habitID)
        }
        
        return managedHabit
    }
    
    
    func fetchHabitRecord(withID habitRecordID: String) throws -> ManagedHabitRecord {
        
        guard let managedHabitRecord = try fetch(ManagedHabitRecord.findHabitRecordRequest(with: habitRecordID)).first else {
            throw HabitRepositoryError.couldNotFindHabitRecordWithID(id: habitRecordID)
        }
        
        return managedHabitRecord
    }
}


extension CoreDataBlockHabitStore {
    
    
    func create(_ habit: Habit) async throws {
        
        let context = context
        try await context.perform {
            
            let managedHabit = ManagedHabit(context: context)
            managedHabit.id = habit.id
            
            try managedHabit.populate(from: habit, in: context)
            managedHabit.habitRecords = nil
            
            // save
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
    
    
    func update(habitID: String, with habit: Habit) async throws {
        
        let context = context
        
        try await context.perform {
            
            let managedHabit = try context.fetchHabit(withID: habitID)
            try managedHabit.populate(from: habit, in: context)
            
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
    
    
    /// Update a habit's `isArchvied` property to true
    func archive(_ habit: Habit) async throws {
        
        var archivedHabit = habit
        archivedHabit.isArchived = true
        
        try await update(habitID: habit.id, with: archivedHabit)
    }
    
    
//    func unarchive() async throws
    
    
    func destroy(_ habit: Habit) async throws {
        
        let context = context
        try await context.perform {
            let managedHabit = try habit.toManaged(context: context)
            context.delete(managedHabit)
            
            // save
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
}



