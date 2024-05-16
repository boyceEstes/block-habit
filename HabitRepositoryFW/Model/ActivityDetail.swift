//
//  ActivityDetail.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation

public struct ActivityDetail: ActivityDetailSortable, Identifiable, Hashable  {
    
    public let id: String
    public let name: String
    public let availableUnits: String?
    public var isArchived: Bool
    public let creationDate: Date
    public let calculationType: ActivityDetailCalculationType
    public let valueType: ActivityDetailType
    
    
    public init(
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
