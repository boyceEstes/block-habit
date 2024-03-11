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
        return NSFetchRequest<ManagedActivityDetailRecord>(entityName: "ManagedActivityDetailRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var value: String?
    @NSManaged public var unit: String?
    @NSManaged public var activityDetail: ManagedActivityDetail?
    @NSManaged public var habitRecord: ManagedHabitRecord?
}


extension ManagedActivityDetailRecord : Identifiable {

}
