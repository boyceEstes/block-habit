//
//  Habit+UI.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 4/29/24.
//

import HabitRepositoryFW
import SwiftUI


public extension Habit {
    
    static let preview = Habit(
        id: UUID().uuidString,
        name: "Chugging Dew",
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        activityDetails: []
    )
}
