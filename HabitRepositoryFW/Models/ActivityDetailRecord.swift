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
    // FIXME: Include `HabitRecord` when it becomes available
    
    
    public init(value: String, unit: String?, activityDetail: ActivityDetail) {
        self.value = value
        self.unit = unit
        self.activityDetail = activityDetail
    }
}


public extension Array where Element == ActivityDetailRecord {
    
    func valueType(_ valueType: ActivityDetailType) -> [ActivityDetailRecord] {
        
        self.filter {
            $0.activityDetail.valueType == valueType
        }
    }
}

