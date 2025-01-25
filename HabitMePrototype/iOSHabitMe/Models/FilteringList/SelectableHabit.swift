//
//  SelectableHabit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI
import HabitRepositoryFW

/*
 * To keep things as simple as I can think, I would want to keep this on the Home Screen and use
 * the existing Bar view on that screen. Interact with that bar view by tapping on filters which
 * would update the stats that will be displayed in this view.
 */

struct SelectableHabit: Hashable, SelectableListItem {

    let id: String
    let name: String
    var isSelected: Bool = true
    var color: Color
    
    // This is kept for easily keeping data that will be needed later
    var habit: Habit
    
    init(habit: Habit) {
        
        self.id = habit.id
        self.name = habit.name
        self.color = habit.readableColor
        self.habit = habit
    }
}
