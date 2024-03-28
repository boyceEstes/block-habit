//
//  Habit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation



public struct IsCompletedHabit {
    
    public let habit: Habit
    public let isCompleted: Bool
}


public struct Habit: Hashable {
    
    public let id: String
    public let name: String
    
    public var isArchived: Bool
    public let goalCompletionsPerDay: Int?
    
    // TODO: Make a computed variable color accessor for the string so this can be private
    public let color: String
    // private let color: String
    // public var colorfulColor: Color { Color(decipherString: color) }
    
    // TODO: Fill in the data for habitRecords and activityDetails that should be known from this struct
    public let activityDetails: [ActivityDetail]
    
    init(
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


struct HabitRecord {
    
    let id: String
    let creationDate: Date?
    let completionDate: Date?
    
    let activityDetailRecords: [ActivityDetailRecord]
    let habit: Habit
}


struct ActivityDetailRecord: Identifiable, Hashable {

    
    let id = UUID().uuidString
    var value: String
    let unit: String?
    
    let activityDetail: ActivityDetail
    // FIXME: Include `HabitRecord` when it becomes available
}


public struct ActivityDetail: ActivityDetailSortable {
    
    public let id: String
    public let name: String
    public let availableUnits: String?
    public let isArchived: Bool
    public let creationDate: Date
    let calculationType: ActivityDetailCalculationType
    let valueType: ActivityDetailType
    
    init(
        id: String,
        name: String,
        availableUnits: String?, 
        isArchived: Bool,
        creationDate: Date,
        calculationType: ActivityDetailCalculationType,
        valueType: ActivityDetailType
    ) {
        self.id = id
        self.name = name
        self.availableUnits = availableUnits
        self.isArchived = isArchived
        self.creationDate = creationDate
        self.calculationType = calculationType
        self.valueType = valueType
    }
}


extension ActivityDetail {
    
    var example: String {
        
        switch valueType {
            
        case .text:
            return "And then he said, 'the hotdog was green the whole time!'"
            
        case .number:
            guard let availableUnits = availableUnits else {
                return "27"
            }
            
            return "27 \(availableUnits)"
        }
    }
}


extension ActivityDetail: Identifiable, Hashable {
    
    static let time = ActivityDetail(
        id: UUID().uuidString,
        name: "Time",
        availableUnits: "minutes",
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .number
        
    )
    
    
    static let amount = ActivityDetail(
        id: UUID().uuidString,
        name: "Amount",
        availableUnits: "fl oz",
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .number

    )
    
    
    static let length = ActivityDetail(
        id: UUID().uuidString,
        name: "Length",
        availableUnits: nil,
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .number
        
    )
    
    
    static let touchdowns = ActivityDetail(
        id: UUID().uuidString,
        name: "Touchdowns",
        availableUnits: nil,
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .number
    )
    
    
    static let note = ActivityDetail(
        id: UUID().uuidString,
        name: "Note",
        availableUnits: nil,
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .text
    )
    
    static let mood = ActivityDetail(
        id: UUID().uuidString,
        name: "Mood",
        availableUnits: nil,
        isArchived: false,
        creationDate: Date(),
        calculationType: .sum,
        valueType: .text
    )
}
