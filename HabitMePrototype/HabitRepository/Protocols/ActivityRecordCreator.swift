//
//  ActivityRecordCreator.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/5/24.
//

import Foundation
import SwiftData


// MARK: Base layer of creating an activity record - this is used to give a single flow of logic for creating activity records within the app
/// This is meant to be a base-level for other, more complicated protocols like `ActivityRecordCreatorOrNavigator` and `ActivityRecordCreatorWithDetails` - Use those
/// to actually use the `createRecord(for:in:)` functionality
protocol ActivityRecordCreator {
    
    var selectedDay: Date { get }
}


extension ActivityRecordCreator {
    
    /// The logic for parsing the dates according to the Business Logic Policy that we have in place and deliver all information necessary to insert into the database
    func parseDatesAndInsertRecord(for activity: DataHabit, activityDetailRecords: [ActivityDetailRecord] = [], in modelContext: ModelContext) {
        
        let (creationDate, completionDate) = ActivityRecordCreationPolicy.calculateDatesForRecord(on: selectedDay)
        
        modelContext.createHabitRecordOnDate(activity: activity, creationDate: creationDate, completionDate: completionDate, activityDetailRecords: activityDetailRecords)
    }
}



// MARK: ActivityRecordCreaterOrNavigator - Used anywhere that we will need to input or navigate to detail insertion (First layer of creation)

/// Allow the conforming instance to create the record or navigate if needed (there are details to be filled first)
protocol ActivityRecordCreatorOrNavigator: ActivityRecordCreator {
    
    var selectedDay: Date { get }
    var goToCreateActivityRecordWithDetails: (DataHabit, Date) -> Void { get }
}


extension ActivityRecordCreatorOrNavigator {
    
    func createRecord(for activity: DataHabit, in modelContext: ModelContext) {
    
        if !activity.activityDetails.isEmpty {
            
            goToCreateActivityRecordWithDetails(activity, selectedDay)
            
        } else {
            
            parseDatesAndInsertRecord(for: activity, in: modelContext)
        }
    }
}


// MARK: ActivityRecordCreatorWithDetails - Used when we have acitivity detail records to input with our habit record (Final layer of creation)
/// Allows the conforming instance to create the record with the details that were required
protocol ActivityRecordCreatorWithDetails: ActivityRecordCreator {
    
    var activityDetailRecords: [ActivityDetailRecord] { get }
}


extension ActivityRecordCreatorWithDetails {
    
    func createRecord(for activity: DataHabit, in modelContext: ModelContext) {
        
        parseDatesAndInsertRecord(for: activity, activityDetailRecords: activityDetailRecords, in: modelContext)
    }
}

