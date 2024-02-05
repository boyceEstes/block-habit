//
//  ActivityDetailRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/5/24.
//

import Foundation


// Creating this tranisent object because having a hard time referencing
// the activities when I map it to a `DataActivityDetailRecord` due to SwiftData
// relationship idiosyncrosies - this allowed me to access my data as I wanted
// NOTE: keeping the ID as a unique identifier, separate from content is important
// so that the row is not reloaded when the keyboard modifies its value (it was
// a id based on the hashvalue before)
struct ActivityDetailRecord: Identifiable, Hashable {

    
    let id = UUID().uuidString
    let activityDetail: DataActivityDetail
    var value: String
    
    
    init(activityDetail: DataActivityDetail, value: String) {
        
        self.activityDetail = activityDetail
        self.value = value
    }
    
    
    static func == (lhs: ActivityDetailRecord, rhs: ActivityDetailRecord) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(value)
        hasher.combine(activityDetail)
    }
}
