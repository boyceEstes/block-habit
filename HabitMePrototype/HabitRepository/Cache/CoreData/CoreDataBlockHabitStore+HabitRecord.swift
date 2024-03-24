//
//  CoreDataBlockHabitStore+HabitRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation


extension CoreDataBlockHabitStore {
    
    func create(_ habitRecord: HabitRecord) async throws {
        
        let context = context
        try await context.perform {
            
            do {
                // Create stuff
                let managedHabitRecord = ManagedHabitRecord(context: context)
                managedHabitRecord.id = habitRecord.id
                managedHabitRecord.creationDate = habitRecord.creationDate
                managedHabitRecord.completionDate = habitRecord.completionDate
                // FIXME: Create with activity detail records
                managedHabitRecord.activityDetailRecords = nil //habitRecord.activityDetailRecords.toManaged(context: context)
                managedHabitRecord.habit = try habitRecord.habit.toManaged(context: context)
                // save
                try context.save()
                
            } catch {
                throw error
            }
        }
    }
}
