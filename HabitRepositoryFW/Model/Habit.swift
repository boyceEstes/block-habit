//
//  Habit.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation


public struct Habit: Hashable {
    
    public let id: String
    public let name: String
    public let creationDate: Date
    
    public var isArchived: Bool
    /// I don't think I actually want this to ever be nil. If there is no goal, make this 0
    public let goalCompletionsPerDay: Int?
    
    // TODO: Make a computed variable color accessor for the string so this can be private
    public let color: String
    // private let color: String
    // public var colorfulColor: Color { Color(decipherString: color) }
    
    // TODO: Fill in the data for habitRecords and activityDetails that should be known from this struct
    public var activityDetails: [ActivityDetail]
    
    
    public var schedulingUnits: ScheduleTimeUnit = .weekly // "Frequency" in Reminders app
    public var rate: Int // "Every" in Reminders App
    public var scheduledWeekDays: Set<ScheduleDay>
    public var reminderTime: Date? = nil
    
    public init(
        id: String,
        name: String,
        creationDate: Date,
        isArchived: Bool,
        goalCompletionsPerDay: Int?,
        color: String,
        activityDetails: [ActivityDetail],
        schedulingUnits: ScheduleTimeUnit = .weekly,
        rate: Int = 1,
        scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays,
        reminderTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.isArchived = isArchived
        self.goalCompletionsPerDay = goalCompletionsPerDay
        self.color = color
        self.activityDetails = activityDetails
        self.schedulingUnits = schedulingUnits
        self.rate = rate
        self.scheduledWeekDays = scheduledWeekDays
        self.reminderTime = reminderTime
    }
}
