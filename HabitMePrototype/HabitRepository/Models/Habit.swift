//
//  Habit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation
import HabitRepositoryFW
 

extension HabitRecord {
    
    static var preview: HabitRecord {
        
        HabitRecord(
            id: UUID().uuidString,
            creationDate: Date(),
            completionDate: Date(),
            activityDetailRecords: [
                ActivityDetailRecord(value: "This is a lot of string, don'tcha know - Where is it I'm going to out\n", unit: nil, activityDetail: .note)
            ],
            habit: Habit.mopTheCarpet
        )
    }
}



extension Array where Element == ActivityDetailRecord {
    
    func bjSort() -> [ActivityDetailRecord] {
        
        // Prioritize number types at the top
        // Sort alphabetically
        var sortedArray = [ActivityDetailRecord]()
        
        let numberActivityDetailRecords = filter { $0.activityDetail.valueType == .number }
        let sortedNumberActivityDetailRecords = numberActivityDetailRecords.sorted {
            $0.activityDetail.name < $1.activityDetail.name
        }
        
        let textActivityDetailRecords = filter {
            $0.activityDetail.valueType == .text
        }
        let sortedTextActivityDetailsRecords = textActivityDetailRecords.sorted {
            $0.activityDetail.name < $1.activityDetail.name
        }
        
        sortedArray.append(contentsOf: sortedNumberActivityDetailRecords)
        sortedArray.append(contentsOf: sortedTextActivityDetailsRecords)
        
        return sortedArray
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


extension ActivityDetail {
    
    // MARK: Text
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
    
    
    
    // MARK: Values
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
}
