//
//  HabitRecordDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import SwiftData

struct HabitRecordDetailView: View {
    
    let dataHabitRecord: DataHabitRecord
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        id: UUID().uuidString,
        name: "Chugged Dew",
        color: Habit.habits[0].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    
    container.mainContext.insert(dataHabit)
    
    let dataHabitRecord = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord)
    
    
    return HabitRecordDetailView(dataHabitRecord: dataHabitRecord)
}
