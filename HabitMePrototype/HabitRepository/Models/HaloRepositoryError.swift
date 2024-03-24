//
//  HaloRepositoryError.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation

enum HabitRepositoryError: Error {
    
    case toModelFailedBecausePropertyWasNil
    case couldNotFindHabitWithId
}
