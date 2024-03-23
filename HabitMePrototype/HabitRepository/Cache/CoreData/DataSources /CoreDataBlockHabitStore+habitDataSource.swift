//
//  CoreDataBlockHabitStore+habitDataSource.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import CoreData

extension CoreDataBlockHabitStore {
    
    func habitDataSource() -> HabitDataSource {
        
        let frc = NSFetchedResultsController(
            fetchRequest: ManagedHabit.allManagedHabitsRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        
        return ManagedHabitFRCDataSourceAdapter(frc: frc)
    }
}
