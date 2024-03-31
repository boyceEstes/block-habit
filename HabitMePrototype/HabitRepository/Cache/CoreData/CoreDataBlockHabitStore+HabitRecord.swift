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
    
    
    func readManagedHabitRecords(for selectedDay: Date) async throws -> [ManagedHabitRecord] {
        
        let context = context
        return try await context.perform {
                
            let habitRecordsForSelectedDayRequest = ManagedHabitRecord.allManagedHabitRecordsRequest(for: selectedDay)
            let managedHabitRecords = try context.fetch(habitRecordsForSelectedDayRequest)
            print("BOYCE: managedHabitRecords for date count: \(managedHabitRecords.count)")
            return managedHabitRecords
        }
    }
    
    
    func update(habitRecordID: String, with habitRecord: HabitRecord) async throws {
        
        let context = context
        try await context.perform {
            
            let managedHabitRecord = try context.fetchHabitRecord(withID: habitRecordID)
            
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
    
    
    func destroy(_ habitRecord: HabitRecord) async throws {
        
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
