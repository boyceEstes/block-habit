//
//  ManagedHabit+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/9/24.
//
//

import Foundation
import CoreData



@objc(ManagedHabit)
public class ManagedHabit: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabit> {
        return NSFetchRequest<ManagedHabit>(entityName: "DataHabit")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var goalCompletionsPerDay: NSNumber?
    @NSManaged public var habitRecords: NSSet? // DataActivityDetails
    @NSManaged public var activityDetails: Set<ManagedActivityDetail>? // DataHabitRecords

    
    public class func allUnarchivedManagedHabitsRequest() -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "isArchived == NO")
        request.predicate = predicate
        
        return request
    }
    
    
    static func findHabitRequest(with id: String) -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        request.predicate = predicate
        
        request.fetchLimit = 1
        
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
        
        let activityDetails: [ActivityDetail] = try activityDetails?.toModel() ?? []
        
        return Habit(
            id: id,
            name: name,
            isArchived: isArchived,
            color: color,
            activityDetails: activityDetails
        )
    }
}


extension Array where Element == ManagedHabit {
    
    func toModel() throws -> [Habit] {
        let habits = try map {
            try $0.toModel()
        }
        return habits
    }
}


extension Habit {
    
    func toManaged(context: NSManagedObjectContext) throws -> ManagedHabit {
        
        return try context.fetchHabit(withID: id)
    }
}


extension ManagedHabit : Identifiable {

}
