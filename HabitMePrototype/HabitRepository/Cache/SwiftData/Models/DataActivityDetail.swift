//
//  DataActivityDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/1/24.
//

import Foundation
import SwiftData


@Model
final class DataActivityDetail: Hashable, Decodable {
    
    enum CodingKeys: CodingKey {
        case name
        case valueType
        case availableUnits
        case isArchived
    }
    
    @Attribute(.unique) var id: String = UUID().uuidString
    
    /// Name of the activity detail
    /// Ex: `Duration`
    var name: String
    
    /// What type of information is being stored here
    /// Ex: `Number` or `Text`
    /// Refrence the below link if there are any problems accessing this property but I think it should be fine
    /// since it is `Codable` and not a `Collection` type
    /// https://www.hackingwithswift.com/quick-start/swiftdata/using-structs-and-enums-in-swiftdata-models#:~:text=Any%20class%20marked%20with%20%40Model,have%20raw%20or%20associated%20values.
    var valueType: ActivityDetailType
    
    /// Additional details to be available when filling out this record
    /// Ex: `Meters`, `Kilograms`, `Minutes`
    var availableUnits: [String]
    
    /// For deleting when an activity detail is deleted, this is so that we do not have to
    /// lose all of the associated records, simply sort by nonArchived when displaying data
    var isArchived: Bool
    
    /// This can be empty - no records are required for this model
    @Relationship(deleteRule: .cascade, inverse: \DataActivityDetailRecord.activityDetail) var detailRecords: [DataActivityDetailRecord]
    
    /// 1 activity detail can be used in many habits - if this is deleted, we don't want to delete all of the associated habits
    /// we only want to nullify the `ActivityDetail` that was previously there
    var habits: [DataHabit]
    
    
    init(
        name: String = "",
        valueType: ActivityDetailType = .text,
        availableUnits: [String] = [],
        isArchived: Bool = false,
        detailRecords: [DataActivityDetailRecord] = [],
        habits: [DataHabit] = []
    ) {
        self.name = name
        self.valueType = valueType
        self.availableUnits = availableUnits
        self.isArchived = isArchived
        self.detailRecords = detailRecords
        self.habits = habits
    }

    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        print("completed name")
        valueType = try container.decode(ActivityDetailType.self, forKey: .valueType)
        print("completed valueType")
        availableUnits = try container.decodeIfPresent([String].self, forKey: .availableUnits) ?? []
        print("completed availableUnits")
//
        // Should always be initialized to this
//        availableUnits = []
        isArchived = false
        detailRecords = []
        habits = []
    }
}


enum ActivityDetailType: String, CaseIterable, Identifiable, Hashable, Codable {
    
    // Very important to have these exact rawValues because they are used to decode seed data
    case number = "Number"
    case text = "Text"
    
    var id: ActivityDetailType { self }
}


extension DataActivityDetail {
    
    var example: String {
        
        switch valueType {
            
        case .text:
            return "And then he said, 'the hotdog was green the whole time!'"
            
        case .number:
            return "27\(availableUnits.isEmpty ? "" : " \(availableUnits.first!)")"
        }
    }
}


@Model
final class DataActivityDetailRecord: Hashable {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    
    /// Value of whatever ActivityDetail that is being logged
    /// Ex: `20`
    /// We can use the `valueType` in `activityDetail` to decide how to interpret this value, but here it will be a string
    /// This is nonoptional because if this is not filled out, then there is no point in creating a record the associated habit/activity
    var value: String
    
    /// Units associatd with the value, there will be none if it is a `Text` in `activityDetail.valueType`
    /// Ex: `minutes`
    var unit: String?
    
    /// This MUST have some associated DataActivityDetail, if it doesn't then there is important data missing
    /// For using this information
    var activityDetail: DataActivityDetail
    
    /// This instance must be associated with a habit record to give more insight into how the user is completing their record
    var activityRecord: DataHabitRecord?
    
    
    init(
        value: String,
        unit: String? = nil,
        activityDetail: DataActivityDetail,
        activityRecord: DataHabitRecord? = nil
    ) {
        self.value = value
        self.unit = unit
        self.activityDetail = activityDetail
        self.activityRecord = activityRecord
    }
}
