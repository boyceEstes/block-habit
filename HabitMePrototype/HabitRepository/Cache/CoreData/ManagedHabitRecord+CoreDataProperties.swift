//
//  ManagedHabitRecord+CoreDataProperties.swift
//  BlockJournalCoreDataDemo
//
//  Created by Boyce Estes on 3/9/24.
//
//

import Foundation
import CoreData


extension ManagedHabitRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabitRecord> {
        return NSFetchRequest<ManagedHabitRecord>(entityName: "ManagedHabitRecord")
    }

    @NSManaged public var id: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var completionDate: Date?
    
    @NSManaged public var activityDetailRecords: NSSet? // [DataActivityDetailRecord]
    @NSManaged public var habit: ManagedHabit? // DataHabit
    
    
    
    public class func allManagedHabitRecordsRequest() -> NSFetchRequest<ManagedHabitRecord> {
        
        let request = ManagedHabitRecord.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabitRecord.completionDate, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}


extension ManagedHabitRecord : Identifiable {

}
