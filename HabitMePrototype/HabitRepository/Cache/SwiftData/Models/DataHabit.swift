//
//  DataHabit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/22/24.
//

import Foundation
import SwiftData

@Model
final class DataHabit: Hashable {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var isArchived: Bool
    var color: String
    
    // if nil, then there is no set of times to log this to make it "completed", they will always appear
    var goalCompletionsPerDay: Int? = nil
    
    // Initializing to empty should cause a lightweight migration, if coming from an earlier version
    @Relationship(deleteRule: .nullify, inverse: \DataActivityDetail.habits) var activityDetails: [DataActivityDetail] = []
    @Relationship(deleteRule: .cascade, inverse: \DataHabitRecord.habit) var habitRecords: [DataHabitRecord]
    
    
    init(
        name: String,
        isArchived: Bool,
        color: String,
        goalCompletionsPerDay: Int? = nil,
        activityDetails: [DataActivityDetail] = [],
        habitRecords: [DataHabitRecord] = []
    ) {
        self.name = name
        self.isArchived = isArchived
        self.color = color
        self.goalCompletionsPerDay = goalCompletionsPerDay
        self.activityDetails = activityDetails
        self.habitRecords = habitRecords
    }
}



@Model
final class DataHabitRecord {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var creationDate: Date
    var completionDate: Date
    var habit: DataHabit?
    // Initializing to empty should cause a lightweight migration, if coming from an earlier version
    @Relationship(deleteRule: .cascade, inverse: \DataActivityDetailRecord.activityRecord) var activityDetailRecords: [DataActivityDetailRecord] = []
    
    
    init(
        creationDate: Date,
        completionDate: Date,
        habit: DataHabit? = nil,
        activityDetailRecords: [DataActivityDetailRecord] = []
    ) {
        self.creationDate = creationDate
        self.completionDate = completionDate
        self.habit = habit
        self.activityDetailRecords = activityDetailRecords
    }
}


// Oh god we're gonna have do conversion for everything.
// The main reason I wanted to have a model was to access variables
// without getting the strange SwiftData relationship fault crashes.
// So even though its a pain, I think its still worth it to do this
// to make the app more consistent.

extension DataHabitRecord {
    
//    func toModel() -> ActivityRecord {
//        
//        ActivityRecord(
//            id: self.id,
//            title: self.habit?.name ?? "Unknown Title",
//            creationDate: self.creationDate,
//            completionDate: self.completionDate,
//            detailRecords: self.activityDetailRecords.toModel()
//        )
//    }
}
