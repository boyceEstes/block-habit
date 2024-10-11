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

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var creationDate: Date
    @NSManaged public var color: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var goalCompletionsPerDay: Int64 // -1 = unset
    @NSManaged public var habitRecords: NSSet? // DataActivityDetails
    @NSManaged public var activityDetails: Set<ManagedActivityDetail>? // DataHabitRecords
    @NSManaged public var schedulingUnits: Int16 // Deciphered from ScheduleTimeUnit
    @NSManaged public var rate: Int16 // Every 'x' Days or Every 'x' weeks
    @NSManaged public var reminderTime: Date? // Nil can absolutely happen, means none was set
    
    
    @NSManaged public var scheduledWeekDaysRaw: NSSet? // Set<Int>
    
    var scheduledWeekDays: Set<Int> {
        get {
            guard let rawDays = scheduledWeekDaysRaw as? Set<Int> else { return [] }
            return rawDays
        }
        set {
            scheduledWeekDaysRaw = newValue as NSSet
        }
    }
    
    
    public class func allManagedHabitsRequest() -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
//    
//    public class func allUnarchivedManagedHabitsRequest() -> NSFetchRequest<ManagedHabit> {
//        
//        let request = ManagedHabit.fetchRequest()
//        request.returnsObjectsAsFaults = false
//        
//        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//        
//        let predicate = NSPredicate(format: "isArchived == NO")
//        request.predicate = predicate
//        
//        return request
//    }
//    
//    
//    public class func allArchivedManagedHabitsRequest() -> NSFetchRequest<ManagedHabit> {
//        
//        let request = ManagedHabit.fetchRequest()
//        request.returnsObjectsAsFaults = false
//        
//        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//        
//        let predicate = NSPredicate(format: "isArchived == YES")
//        request.predicate = predicate
//        
//        return request
//    }
//    
    
    
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
        
        // I want to represent no "goalCompletionsPerDay" as a null value instead of a "-1" in the model
        // This is my favorite option given the Core Data constraints
        return Habit(
            id: id,
            name: name,
            creationDate: creationDate,
            isArchived: isArchived,
            goalCompletionsPerDay: goalCompletionsPerDay == -1 ? nil : Int(goalCompletionsPerDay),
            color: color,
            activityDetails: activityDetails,
            schedulingUnits: ScheduleTimeUnit(rawValue: Int(schedulingUnits)) ?? .weekly,
            rate: Int(rate),
            scheduledWeekDays: Set(scheduledWeekDays.compactMap { ScheduleDay(rawValue: $0) }),
            reminderTime: reminderTime
        )
    }
}


public extension Array where Element == ManagedHabit {
    
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

    func populate(from habit: Habit, in context: NSManagedObjectContext) throws {
        
        name = habit.name
        // Do not put the isArchived because it will be false by default, which is good
        isArchived = habit.isArchived
        // It is not optional because I am storing as a scalable value
        goalCompletionsPerDay = Int64(habit.goalCompletionsPerDay ?? -1)

        color = habit.color
        activityDetails = try habit.activityDetails.toManaged(context: context)
        
        schedulingUnits = Int16(habit.schedulingUnits.rawValue)
        rate = Int16(habit.rate)
        scheduledWeekDays = Set(habit.scheduledWeekDays.map { $0.rawValue })
        reminderTime = habit.reminderTime
        
    }
}
