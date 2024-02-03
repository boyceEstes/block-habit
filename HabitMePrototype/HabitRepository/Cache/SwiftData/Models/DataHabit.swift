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
    var color: String
    @Relationship(deleteRule: .nullify, inverse: \DataActivityDetail.habits) var activityDetails: [DataActivityDetail]
    @Relationship(deleteRule: .cascade, inverse: \DataHabitRecord.habit) var habitRecords: [DataHabitRecord]
    
    
    init(
        name: String,
        color: String,
        activityDetails: [DataActivityDetail] = [],
        habitRecords: [DataHabitRecord] = []
    ) {
        self.name = name
        self.color = color
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
    @Relationship(deleteRule: .cascade, inverse: \DataActivityDetailRecord.activityRecord) var activityDetailRecords: [DataActivityDetailRecord]
    
    
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
