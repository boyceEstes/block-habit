//
//  ManagedHabitRecord+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/9/24.
//
//

import Foundation
import CoreData



@objc(ManagedHabitRecord)
public class ManagedHabitRecord: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabitRecord> {
        return NSFetchRequest<ManagedHabitRecord>(entityName: "DataHabitRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var completionDate: Date?
    
    @NSManaged public var activityDetailRecords: Set<ManagedActivityDetailRecord>? // [DataActivityDetailRecord]
    @NSManaged public var habit: ManagedHabit? // DataHabit
    
    
    static func findHabitRecordRequest(with id: String) -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        request.predicate = predicate
        
        request.fetchLimit = 1
        
        return request
    }
    
    
    /// Used in DataSource to fetch habit records for a given habit
    static func findHabitRecordsRequest(for managedHabit: ManagedHabit) -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabitRecord.completionDate, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "habit == %@", managedHabit)
        request.predicate = predicate
        
        return request
    }
    
    
    public class func allManagedHabitRecordsRequest() -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabitRecord.completionDate, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    
//     FIXME: Remove this if it becomes evident that we can do the same thing by passing in the [HabitRecords] retrieved some other source when configuring our HabitDataSource
/// This isn't great because it has to be formatted exactly as it was saved. In this case it is usually saved a `noon`
    public class func allManagedHabitRecordsRequest(for date: Date) -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptorCompletion = NSSortDescriptor(keyPath: \ManagedHabitRecord.completionDate, ascending: false)
        let sortDescriptorCreation = NSSortDescriptor(keyPath: \ManagedHabitRecord.creationDate, ascending: false)
        request.sortDescriptors = [sortDescriptorCompletion, sortDescriptorCreation]
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        print("BOYCE: date: '\(DateFormatter.shortDateShortTime.string(from: date))'")
        print("BOYCE: startDate: '\(DateFormatter.shortDateShortTime.string(from: startDate))'")
        print("BOYCE: endDate: '\(DateFormatter.shortDateShortTime.string(from: endDate))'")
        
        let predicate = NSPredicate(format: "completionDate >= %@ AND completionDate < %@", startDate as NSDate, endDate as NSDate)
        request.predicate = predicate
        
        return request
    }
}


extension ManagedHabitRecord : Identifiable {

}


extension ManagedHabitRecord {
    
    func toModel() throws -> HabitRecord {
        
        guard let id, let creationDate, let completionDate, let habit else {
            throw HabitRepositoryError.toModelFailedBecausePropertyWasNil
        }
        
        
        // FIXME: Make sure to convert the activitydetailrecords
        return HabitRecord(
            id: id,
            creationDate: creationDate,
            completionDate: completionDate,
            activityDetailRecords: [],
            habit: try habit.toModel()
        )
    }
}


extension Array where Element == ManagedHabitRecord {
    
    func toModel() throws -> [HabitRecord] {
        try map { try $0.toModel() }.sorted {
            if $0.completionDate == $1.completionDate {
                return $0.creationDate > $1.creationDate
            } else {
                return $0.completionDate > $1.completionDate
            }
        }
    }
}


extension HabitRecord {
    
    func toManaged(context: NSManagedObjectContext) throws -> ManagedHabitRecord {
        
        return try context.fetchHabitRecord(withID: id)
    }
}
