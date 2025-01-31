//
//  CoreDataBlockHabitStore+habitDataSource.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import CoreData

extension CoreDataBlockHabitStore {
    
//    public func habitDataSource(selectedDay: Date) -> HabitDataSource {
//        
//        
//        let frc = NSFetchedResultsController(
//            fetchRequest: ManagedHabit.allUnarchivedManagedHabitsRequest(),
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        
//        return ManagedHabitFRCDataSourceAdapter(
//            frc: frc,
//            selectedDay: selectedDay,
//            getHabitRecordsForDay: { [weak self] dataSourceSelectedDay in
//                
//                guard let self else {
//                    print("FAILED to get coredatablockhabitstore - out of memory")
//                    return []
//                }
//                
//                return try await self.readManagedHabitRecords(for: dataSourceSelectedDay)
//            }
//        )
//    }
    
    
    public func habitRecordsByDateDataSource() -> HabitRecordsByDateDataSource {
        
        let frc = NSFetchedResultsController(
            fetchRequest: ManagedHabitRecord.allManagedHabitRecordsRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return ManagedHabitRecordsForDateFRCDataSourceAdapter(frc: frc)
    }
    
    
    public func habitRecordsByDateForHabitDataSource(habit: Habit) throws -> HabitRecordsByDateDataSource {
        
        let managedHabit = try habit.toManaged(context: context)
        
        let frc = NSFetchedResultsController(
            fetchRequest: ManagedHabitRecord.findHabitRecordsRequest(for: managedHabit),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return ManagedHabitRecordsForDateFRCDataSourceAdapter(frc: frc)
    }
}
