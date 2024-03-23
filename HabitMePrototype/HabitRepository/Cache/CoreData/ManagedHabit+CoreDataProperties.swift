//
//  ManagedHabit+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/9/24.
//
//

import Foundation
import CoreData


enum HabitRepositoryError: Error {
    
    case toModelFailedBecausePropertyWasNil
}


extension ManagedHabit {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabit> {
        return NSFetchRequest<ManagedHabit>(entityName: "DataHabit")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
//    @NSManaged public var isArchived: Bool
//    @NSManaged public var completionGoalsPerDay: Double
    @NSManaged public var habitRecords: NSSet? // DataActivityDetails
    @NSManaged public var activityDetails: NSSet? // DataHabitRecords

    
    public class func allManagedHabitsRequest() -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}


// MARK: Generated accessors for habitRecords
extension ManagedHabit {

    @objc(addHabitRecordsObject:)
    @NSManaged public func addToHabitRecords(_ value: ManagedHabitRecord)

    @objc(removeHabitRecordsObject:)
    @NSManaged public func removeFromHabitRecords(_ value: ManagedHabitRecord)

    @objc(addHabitRecords:)
    @NSManaged public func addToHabitRecords(_ values: NSSet)

    @objc(removeHabitRecords:)
    @NSManaged public func removeFromHabitRecords(_ values: NSSet)

}


extension ManagedHabit {
    
    func toModel() throws -> Habit {
        
        guard let id, let name, let color else {
            throw HabitRepositoryError.toModelFailedBecausePropertyWasNil
        }
        
        return Habit(id: id, name: name, color: color, activityDetails: [])
    }
}


extension Array where Element == ManagedHabit {
    
    func toModel() throws -> [Habit] {
        try map {
            try $0.toModel()
        }
    }
}


extension ManagedHabit : Identifiable {

}


