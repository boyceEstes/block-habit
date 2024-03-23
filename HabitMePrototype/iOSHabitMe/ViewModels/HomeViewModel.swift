//
//  HomeViewModel.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation


@Observable
class HomeViewModel {
    
    let blockHabitStore: CoreDataBlockHabitStore
//    let habitDataSource: HabitDataSource
    
    
    init(blockHabitStore: CoreDataBlockHabitStore) {
        
        self.blockHabitStore = blockHabitStore
//        habitDataSource = blockHabitStore.habitDataSource()
    }
}
