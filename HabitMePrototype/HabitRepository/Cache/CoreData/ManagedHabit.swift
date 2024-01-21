//
//  ManagedHabit+CoreDataClass.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//
//

import Foundation
import CoreData

@objc(ManagedHabit)
public class ManagedHabit: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabit> {
        return NSFetchRequest<ManagedHabit>(entityName: "ManagedHabit")
    }

    @NSManaged public var name: String?
    @NSManaged public var colorHexString: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var habitRecords: NSSet?
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
