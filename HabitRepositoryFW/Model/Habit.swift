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
    
    public var isArchived: Bool
    /// I don't think I actually want this to ever be nil. If there is no goal, make this 0
    public let goalCompletionsPerDay: Int?
    
    // TODO: Make a computed variable color accessor for the string so this can be private
    public let color: String
    // private let color: String
    // public var colorfulColor: Color { Color(decipherString: color) }
    
    // TODO: Fill in the data for habitRecords and activityDetails that should be known from this struct
    public var activityDetails: [ActivityDetail]
    
    public init(
        id: String,
        name: String,
        isArchived: Bool,
        goalCompletionsPerDay: Int?,
        color: String,
        activityDetails: [ActivityDetail]
    ) {
        self.id = id
        self.name = name
        self.isArchived = isArchived
        self.goalCompletionsPerDay = goalCompletionsPerDay
        self.color = color
        self.activityDetails = activityDetails
    }
}

