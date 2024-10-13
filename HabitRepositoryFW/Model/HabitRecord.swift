//
//  HabitRecord.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation



public struct HabitRecord: Hashable {
    
    public let id: String
    public let creationDate: Date
    public var completionDate: Date
    
    public var activityDetailRecords: [ActivityDetailRecord]
    public let habit: Habit
    
    
    public init(id: String, creationDate: Date, completionDate: Date, activityDetailRecords: [ActivityDetailRecord], habit: Habit) {
        
        self.id = id
        self.creationDate = creationDate
        self.completionDate = completionDate
        self.activityDetailRecords = activityDetailRecords
        self.habit = habit
    }
}
