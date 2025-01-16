//
//  Array+ActivityDetailRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/14/25.
//

import Foundation


public extension Array where Element == ActivityDetailRecord {
    
    func bjSort() -> [ActivityDetailRecord] {
        
        // Step 1: Extract all the activity details and sort them using your custom method
        let sortedDetails = Set(self.map { $0.activityDetail }).bjSort()
        
        // Step 2: Create a dictionary to store the sorted position of each detail for quick lookup
        let positionMap = Dictionary(uniqueKeysWithValues: sortedDetails.enumerated().map { ($1, $0) })
        
        // Step 3: Sort the records using the precomputed positions
        return self.sorted {
            positionMap[$0.activityDetail, default: Int.max] < positionMap[$1.activityDetail, default: Int.max]
        }
    }
    
    
    func summary() -> String {
        
        let sortedActivityDetailRecords = self.bjSort()
        
        // We want to sort everything the same way...
        // Numbers first, then Notes
        // For multiples of Numbers or Strings - sort in alphabetical order
        var summary: String = ""
        
        for i in 0..<sortedActivityDetailRecords.count {
            let label = sortedActivityDetailRecords[i].activityDetail.name
            let units = sortedActivityDetailRecords[i].activityDetail.availableUnits
            let value = sortedActivityDetailRecords[i].value.isEmpty ? "N/A" : sortedActivityDetailRecords[i].value
            
            if i != sortedActivityDetailRecords.count - 1 {
                // If we are not at the last index, append with ", " to prep for next one
                summary += "\(label): \(value)\(units != nil ? " \(units!)" : ""), "
            } else {
                summary += "\(label): \(value)\(units != nil ? " \(units!)" : "")"
            }
        }
        
        return summary
    }
}
