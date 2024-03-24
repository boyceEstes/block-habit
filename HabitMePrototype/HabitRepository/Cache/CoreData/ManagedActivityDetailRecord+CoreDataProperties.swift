//
//  ManagedActivityDetailRecord+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/10/24.
//
//

import Foundation
import CoreData


extension ManagedActivityDetailRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedActivityDetailRecord> {
        return NSFetchRequest<ManagedActivityDetailRecord>(entityName: "DataActivityDetailRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var value: String?
    @NSManaged public var unit: String?
    @NSManaged public var activityDetail: ManagedActivityDetail?
    @NSManaged public var activityRecord: ManagedHabitRecord?
}


extension ManagedActivityDetailRecord : Identifiable {

}

// FIXME: Create managed ActivityDetailRecord when we can successfully fetch it or create all its pieces - looking at you, fetching activityDetail
//extension Array where Element == ActivityDetailRecord {
//    
//    func toManaged(context: NSManagedObjectContext) -> Set<ManagedActivityDetailRecord> {
//        
//        let managedActivityDetailRecords = map {
//            let managedActivityDetailRecord = ManagedActivityDetailRecord(context: context)
//            managedActivityDetailRecord.id = $0.id
//            managedActivityDetailRecord.value = $0.value
//            managedActivityDetailRecord.unit = $0.unit
//            managedActivityDetailRecord.activityDetail = $0.activityDetail.toManaged(context: context)
//        }
//    }
//}
