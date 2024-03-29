//
//  ActivityDetailRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/5/24.
//

import Foundation



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


extension Array where Element == ActivityDetailRecord {
    
    func valueType(_ valueType: ActivityDetailType) -> [ActivityDetailRecord] {
        
        self.filter {
            $0.activityDetail.valueType == valueType
        }
    }
}
