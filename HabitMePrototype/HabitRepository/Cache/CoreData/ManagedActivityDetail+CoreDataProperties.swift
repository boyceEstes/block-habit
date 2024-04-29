//
//  ManagedActivityDetail+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/10/24.
//
//

import Foundation
import CoreData
import HabitRepositoryFW


@objc(ManagedActivityDetail)
public class ManagedActivityDetail: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedActivityDetail> {
        return NSFetchRequest<ManagedActivityDetail>(entityName: "DataActivityDetail")
    }

    @NSManaged public var id: String?
    
    @NSManaged public var name: String?
    
    @NSManaged public var availableUnits: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var stringlyCalculationType: String
    @NSManaged public var stringlyValueType: String
    
    @NSManaged public var detailRecords: NSSet? // [DataActivityDetailRecord]
    @NSManaged public var habits: NSSet? // [DataHabit]
    
    
    static func findActivityDetail(with id: String) -> NSFetchRequest<ManagedActivityDetail> {
        
        let request = ManagedActivityDetail.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        request.predicate = predicate
        
        request.fetchLimit = 1
        
        return request
    }
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


extension ManagedActivityDetail {
    
    func toModel() throws -> ActivityDetail {
        
        guard let id, let name, let creationDate else {
            throw HabitRepositoryError.toModelFailedBecausePropertyWasNil
        }
        
        let valueType = ActivityDetailType(rawValue: stringlyValueType) ?? .text
        let calculationType = ActivityDetailCalculationType(rawValue: stringlyCalculationType) ?? .sum
        
        return ActivityDetail(
            id: id,
            name: name,
            availableUnits: availableUnits,
            isArchived: isArchived,
            creationDate: creationDate,
            calculationType: calculationType,
            valueType: valueType
        )
    }
}


extension ActivityDetail {
    
    /// Called by creating ActivityDetailRecord on HabitRecord
    /// Searches for an activityDetail matching the one that is being saved, if it is not found throw an error
    func toManaged(context: NSManagedObjectContext) throws -> ManagedActivityDetail {
        
        guard let managedActivityDetail = try context.fetch(ManagedActivityDetail.findActivityDetail(with: id)).first else {
            throw HabitRepositoryError.couldNotFindActivityDetailWithID
        }
        
        return managedActivityDetail
    }
}


extension Array where Element == ActivityDetail {
    
    func toManaged(context: NSManagedObjectContext) throws -> Set<ManagedActivityDetail> {
        
        Set(try map { try $0.toManaged(context: context) })
    }
}


extension Set where Element == ManagedActivityDetail {
    
    func toModel() throws -> [ActivityDetail] {
        
        try map {
            try $0.toModel()
        }
    }
}


extension ManagedActivityDetail : Identifiable {

}

