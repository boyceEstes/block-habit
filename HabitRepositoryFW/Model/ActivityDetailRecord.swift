//
//  ActivityDetailRecord.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation



public struct ActivityDetailRecord: Identifiable, Hashable {

    
    public let id = UUID().uuidString
    public var value: String
    public let unit: String?
    
    public let activityDetail: ActivityDetail
    /// Set to nil when we are saving new activityDetailRecords - because we make the instance of habitRecord after the activityDetailRecord. It is unnecessary as core data will setup the relationship correctly with just adding the array of activityDetailRecords to habitRecord
    ///
    /// We do need this value though to make it easier for us to calculate the chart data from the detail habit view - 
    public var habitRecord: HabitRecord?
    // FIXME: Include `HabitRecord` when it becomes available
    
    
    public init(value: String, unit: String?, activityDetail: ActivityDetail, habitRecord: HabitRecord? = nil) {
        self.value = value
        self.unit = unit
        self.activityDetail = activityDetail
        self.habitRecord = habitRecord
    }
}


public extension Array where Element == ActivityDetailRecord {
    
    func valueType(_ valueType: ActivityDetailType) -> [ActivityDetailRecord] {
        
        self.filter {
            $0.activityDetail.valueType == valueType
        }
    }
}

