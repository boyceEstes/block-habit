//
//  ManagedActivityDetail+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/10/24.
//
//

import Foundation
import CoreData


extension ManagedActivityDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedActivityDetail> {
        return NSFetchRequest<ManagedActivityDetail>(entityName: "ManagedActivityDetail")
    }

    @NSManaged public var name: String?
    @NSManaged public var valueType: String?
    @NSManaged public var availableUnits: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var calculationType: String?
    @NSManaged public var id: String?
    
    @NSManaged public var detailRecords: NSSet?
    @NSManaged public var habits: NSSet?
}


// MARK: Generated accessors for detailRecords
extension ManagedActivityDetail {

    @objc(addDetailRecordsObject:)
    @NSManaged public func addToDetailRecords(_ value: ManagedActivityDetailRecord)

    @objc(removeDetailRecordsObject:)
    @NSManaged public func removeFromDetailRecords(_ value: ManagedActivityDetailRecord)

    @objc(addDetailRecords:)
    @NSManaged public func addToDetailRecords(_ values: NSSet)

    @objc(removeDetailRecords:)
    @NSManaged public func removeFromDetailRecords(_ values: NSSet)

    
    public class func allManagedActivityDetailsRequest() -> NSFetchRequest<ManagedActivityDetail> {
        
        let request = ManagedActivityDetail.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedActivityDetail.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}


// MARK: Generated accessors for habits
extension ManagedActivityDetail {

    @objc(addHabitsObject:)
    @NSManaged public func addToHabits(_ value: ManagedHabit)

    @objc(removeHabitsObject:)
    @NSManaged public func removeFromHabits(_ value: ManagedHabit)

    @objc(addHabits:)
    @NSManaged public func addToHabits(_ values: NSSet)

    @objc(removeHabits:)
    @NSManaged public func removeFromHabits(_ values: NSSet)

}

extension ManagedActivityDetail : Identifiable {

}
