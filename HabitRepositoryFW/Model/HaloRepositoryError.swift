//
//  HaloRepositoryError.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation

enum HabitRepositoryError: Error {
    
    case toModelFailedBecausePropertyWasNil
    // TODO: make Id into ID
    case couldNotFindHabitWithID(id: String)
    case couldNotFindHabitRecordWithID(id: String)
    case couldNotFindActivityDetailWithID
}
