//
//  DataHabit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/22/24.
//

import Foundation
import SwiftData


@Model
final class DataHabit: Hashable {

    
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var color: String
    @Relationship(deleteRule: .cascade, inverse: \DataHabitRecord.habit) var habitRecords: [DataHabitRecord]
    
    init(id: String = UUID().uuidString, name: String, color: String, habitRecords: [DataHabitRecord]) {
        self.name = name
        self.color = color
        self.habitRecords = habitRecords
    }
}


@Model
final class DataHabitRecord {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var creationDate: Date
    var completionDate: Date
    var habit: DataHabit
    
    
    init(creationDate: Date, completionDate: Date, habit: DataHabit) {
        self.creationDate = creationDate
        self.completionDate = completionDate
        self.habit = habit
    }
}
