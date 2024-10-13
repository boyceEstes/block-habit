//
//  ManagedActivityDetailRecord+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/10/24.
//
//

import Foundation
import CoreData


@objc(ManagedActivityDetailRecord)
public class ManagedActivityDetailRecord: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedActivityDetailRecord> {
        return NSFetchRequest<ManagedActivityDetailRecord>(entityName: "DataActivityDetailRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var value: String?
    @NSManaged public var unit: String?
    @NSManaged public var activityDetail: ManagedActivityDetail?
    @NSManaged public var activityRecord: ManagedHabitRecord?
    
    
    static func findHabitRecordRequest(with id: String) -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        request.predicate = predicate
        
        request.fetchLimit = 1
        
        return request
    }
}


extension ManagedActivityDetailRecord : Identifiable {}


extension Array where Element == ActivityDetailRecord {
    
    // FIXME: What happens when we are trying to update a single activityDetailRecord - we do not want to create a duplicate on accident
    // This doesn't work if you are trying to update (I think) but we can coast on using SwiftData for this for now
    func toManaged(context: NSManagedObjectContext) throws -> Set<ManagedActivityDetailRecord> {
        
        let managedActivityDetailRecords = try map {
            
            let managedActivityDetailRecord = ManagedActivityDetailRecord(context: context)
            managedActivityDetailRecord.id = $0.id
            managedActivityDetailRecord.value = $0.value
            managedActivityDetailRecord.unit = $0.unit
            managedActivityDetailRecord.activityDetail = try $0.activityDetail.toManaged(context: context)

            return managedActivityDetailRecord
        }
        
        return Set(managedActivityDetailRecords)
    }
}


extension Set where Element == ManagedActivityDetailRecord {
    
    func toModel(for habitRecord: HabitRecord) throws -> [ActivityDetailRecord] {
        
        try map { managedActivityDetailRecord in
            
            guard let value = managedActivityDetailRecord.value,
                  let activityDetail = managedActivityDetailRecord.activityDetail
            else {
                throw HabitRepositoryError.toModelFailedBecausePropertyWasNil
            }
            
            return ActivityDetailRecord(
                value: value,
                unit: managedActivityDetailRecord.unit,
                activityDetail: try activityDetail.toModel(),
                habitRecord: habitRecord
            )
        }
    }
}
