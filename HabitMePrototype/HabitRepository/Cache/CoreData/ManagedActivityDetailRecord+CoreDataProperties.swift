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
}


extension ManagedActivityDetailRecord : Identifiable {}


// FIXME: Create managed ActivityDetailRecord when we can successfully fetch it or create all its pieces - looking at you, fetching activityDetail
extension Array where Element == ActivityDetailRecord {
    
    // FIXME: What happens when we are trying to update a single activityDetailRecord - we do not want to create a duplicate on accident
    func toManaged(context: NSManagedObjectContext) throws -> Set<ManagedActivityDetailRecord> {
        
        let managedActivityDetailRecords = try map {
            let managedActivityDetailRecord = ManagedActivityDetailRecord(context: context)
            managedActivityDetailRecord.id = $0.id
            managedActivityDetailRecord.value = $0.value
            managedActivityDetailRecord.unit = $0.unit
            managedActivityDetailRecord.activityDetail = try $0.activityDetail.toManaged(context: context)
            // FIXME: Verify that this is entered for the right habit - We have not set the "activityRecord" - but that will be okay becaues when we update the activityDetailRecords in the createHabit record this should be okay
            return managedActivityDetailRecord
        }
        
        return Set(managedActivityDetailRecords)
    }
}
