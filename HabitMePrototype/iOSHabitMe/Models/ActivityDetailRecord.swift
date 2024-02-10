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



// I'm upgrading this because I want an easy way to hold all of the useful data
// delivering this information to views. I do not need this to be modifiable.
// It should reload when there is a change in the database with the latest updates
// TODO: Deprecate the original record
struct ActivityDetailRecord2: Identifiable, Hashable {
    
    let id: String
    
    let value: String
    let detail: ActivityDetail
    
    init(id: String = UUID().uuidString, value: String, detail: ActivityDetail) {
        
        self.id = id
        self.value = value
        self.detail = detail
    }
}


struct ActivityDetail: Identifiable, Hashable {
    
    let id: String
    
    let name: String
    let valueType: ActivityDetailType
    let units: String?
    
    init(id: String = UUID().uuidString, name: String, valueType: ActivityDetailType, units: String? = nil) {
        
        self.id = id
        self.name = name
        self.valueType = valueType
        self.units = units
    }
}


struct ActivityRecord: Identifiable, Hashable {
    
    let id: String
    
    let title: String
    let creationDate: Date
    let completionDate: Date
    let detailRecords: [ActivityDetailRecord2]
    
    init(
        id: String = UUID().uuidString,
        title: String,
        creationDate: Date,
        completionDate: Date,
        detailRecords: [ActivityDetailRecord2]
    ) {
        
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.completionDate = completionDate
        self.detailRecords = detailRecords
    }
    
    
    var displayableCompletionDate: String {
        
        DateFormatter.shortDateShortTime.string(from: completionDate)
    }
}


extension Array where Element == ActivityDetailRecord2 {
    
    func valueType(_ valueType: ActivityDetailType) -> [ActivityDetailRecord2] {
        
        self.filter {
            $0.detail.valueType == valueType
        }
    }
}
