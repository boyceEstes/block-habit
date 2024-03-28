//
//  CoreDataBlockHabitStore+habitDataSource.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import CoreData

extension CoreDataBlockHabitStore {
    
    func habitDataSource(selectedDay: Date) -> HabitDataSource {
        
        
        let frc = NSFetchedResultsController(
            fetchRequest: ManagedHabit.allUnarchivedManagedHabitsRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return ManagedHabitFRCDataSourceAdapter(
            frc: frc,
            getHabitRecordsForDay: { [weak self] in
                
                guard let self else {
                    print("FAILED to get coredatablockhabitstore - out of memory")
                    return []
                }
                
                return try await self.readManagedHabitRecords(for: selectedDay)
            }
        )
    }
}
