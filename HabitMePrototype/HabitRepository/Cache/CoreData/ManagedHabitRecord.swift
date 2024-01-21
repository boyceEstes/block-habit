//
//  ManagedHabitRecord+CoreDataClass.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//
//

import Foundation
import CoreData

@objc(ManagedHabitRecord)
public class ManagedHabitRecord: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabitRecord> {
        return NSFetchRequest<ManagedHabitRecord>(entityName: "ManagedHabitRecord")
    }

    @NSManaged public var completionDate: Date?
    @NSManaged public var creationDate: Date?
    @NSManaged public var habit: ManagedHabit?

}
