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
}
