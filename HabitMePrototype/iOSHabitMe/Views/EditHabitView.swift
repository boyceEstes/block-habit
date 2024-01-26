//
//  EditHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI
import SwiftData


struct EditHabitView: View {
    
    let habit: DataHabit
    
    var body: some View {
        Text("Edit Habit View - \(habit.name)")
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        id: UUID().uuidString,
        name: "Chugging Dew",
        color: Habit.habits.randomElement()?.color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    
    return EditHabitView(habit: dataHabit)
}
