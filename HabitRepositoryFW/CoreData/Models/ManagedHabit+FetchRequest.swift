//
//  ManagedHabit+FetchRequest.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/1/24.
//

import Foundation
import CoreData

extension ManagedHabit {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedHabit> {
        return NSFetchRequest<ManagedHabit>(entityName: "DataHabit")
    }
    
    
    class func habitsMenuRequest() -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}
