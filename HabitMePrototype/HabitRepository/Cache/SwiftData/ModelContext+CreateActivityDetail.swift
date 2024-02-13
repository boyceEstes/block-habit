//
//  ModelContext+CreateActivityDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/13/24.
//
import Foundation
import SwiftData


extension ModelContext {
    
    func createActivityDetail(
        name: String,
        valueType: ActivityDetailType,
        units: String?
    ) {
        
        let creationDate = Date()
        let unitsArray = units != nil && valueType == .number ? [units!] : []
        
        let activityDetail = DataActivityDetail(
            name: name,
            valueType: valueType,
            availableUnits: unitsArray,
            isArchived: false,
            creationDate: creationDate,
            detailRecords: [],
            habits: []
        )
        
        self.insert(activityDetail)
    }
}
