//
//  CoreDataBlockHabitStore+BlockHabitRepository.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/4/24.
//

import Foundation


extension CoreDataBlockHabitStore: BlockHabitRepository {
    
    public func createHabit(_ habit: Habit) async throws {

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
    
    
    public func readAllNonarchivedHabits() async throws -> [Habit] {

        let context = context
        return try await context.perform {
                
            let unarchivedHabitsRequest = ManagedHabit.allUnarchivedManagedHabitsRequest()
            let managedUnarchivedHabits = try context.fetch(unarchivedHabitsRequest)
            print("BOYCE: managedHabitRecords for date count: \(managedUnarchivedHabits.count)")
            return try managedUnarchivedHabits.toModel()
        }
    }
    
    
    public func updateHabit(id: String, with habit: Habit) async throws {

        let context = context
        
        try await context.perform {
            
            let managedHabit = try context.fetchHabit(withID: id)
            try managedHabit.populate(from: habit, in: context)
            
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
    
    
    public func destroyHabit(_ habit: Habit) async throws {
        // TODO: later
    }
    
    
    // MARK: BlockHabitRepository
    
    public func createHabitRecord(_ habitRecord: HabitRecord) async throws {
        
        let context = context
        try await context.perform {
            
            do {
                // Create stuff
                let managedHabitRecord = ManagedHabitRecord(context: context)
                managedHabitRecord.id = habitRecord.id
                managedHabitRecord.creationDate = habitRecord.creationDate
                managedHabitRecord.completionDate = habitRecord.completionDate
                managedHabitRecord.activityDetailRecords = try habitRecord.activityDetailRecords.toManaged(context: context)
                managedHabitRecord.habit = try habitRecord.habit.toManaged(context: context)
                
                print("BOYCE: ActivityDetailRecord count when saving the habit record: '\(habitRecord.activityDetailRecords)'")
                print("BOYCE: ManagedActivityDetailRecord count when saving the managedHabitRecord: '\(managedHabitRecord.activityDetailRecords?.count ?? -1)'")
                
                // save
                try context.save()
                
            } catch {
                // FIXME: Rollback if there is an error
                throw error
            }
        }
    }
    
    
    /// expected to be in order by completionDate when returned - this makes it easier to do further calculations
    public func readAllHabitRecords() async throws -> [HabitRecord] {
        
        let context = context
        return try await context.perform {
                
            let habitRecordsForSelectedDayRequest = ManagedHabitRecord.allManagedHabitRecordsRequest()
            let managedHabitRecords = try context.fetch(habitRecordsForSelectedDayRequest)
            print("BOYCE: managedHabitRecords for date count: \(managedHabitRecords.count)")
            return try managedHabitRecords.toModel()
        }
    }
    
    public func updateHabitRecord(id: String, with habitRecord: HabitRecord) async throws {

        let context = context
        try await context.perform {
            
            let managedHabitRecord = try context.fetchHabitRecord(withID: id)
            
            managedHabitRecord.creationDate = habitRecord.creationDate
            managedHabitRecord.completionDate = habitRecord.completionDate
            
            
            // Can I have a dictionary organized by activityDetailRecord ID's?
            // Then when I want to find a particular one I can
            for activityDetailRecord in habitRecord.activityDetailRecords {
                // For each activityDetailRecord
                // Create a new managed one and delete the old ones?
                if let managedActivityDetailRecord = managedHabitRecord.activityDetailRecords?.first(where: { managedActivityDetailRecord in
                    managedActivityDetailRecord.id == activityDetailRecord.id
                }) {
                    // If we can find a managedActivityDetailRecord that matches the id of one in our model
                    // Value is the only thing that really needs to be modified
                    managedActivityDetailRecord.value = activityDetailRecord.value
                }
            }
            
            // save
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
    
    public func destroyHabitRecord(_ habitRecord: HabitRecord) async throws {
        
        let context = context
        try await context.perform {
            let managedHabitRecord = try habitRecord.toManaged(context: context)
            context.delete(managedHabitRecord)
            
            // save
            try context.save()
            // FIXME: Rollback if there is an error
        }
    }
}
