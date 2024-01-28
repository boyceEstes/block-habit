//
//  StatisticsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/27/24.
//

import SwiftUI
import SwiftData

/*
 * To keep things as simple as I can think, I would want to keep this on the Home Screen and use
 * the existing Bar view on that screen. Interact with that bar view by tapping on filters which
 * would update the stats that will be displayed in this view.
 */

struct SelectableHabit: Hashable {
    
    let habit: DataHabit
    var isSelected: Bool = true
}

struct StatisticsView: View {
    
    @Query(sort: [
        SortDescriptor(\DataHabitRecord.completionDate, order: .reverse),
        SortDescriptor(\DataHabitRecord.creationDate, order: .reverse)
    ], animation: .default) var dataHabitRecords: [DataHabitRecord]
    
    @Query var dataHabits: [DataHabit]
    
    @State private var selectableHabits = [SelectableHabit]()
    @State private var datesWithHabitRecords = [Date: [DataHabitRecord]]()
    private var selectedDay = Date() // This is just for scrolling to the end of the chart
    
    // Basic stats
    private var totalRecords: Int { dataHabitRecords.count }
    
    private var avgRecordsPerDay: Double {
        
        guard totalDays != 0 else { return 0 }
        return Double(totalRecords)/Double(totalDays)
    }
    
    private var mostCompletions: (recordCount: Int, habit: DataHabit)? {
        var maxRecords = 0
        var maxHabit: DataHabit?
        
        for dataHabit in dataHabits {
            let habitRecordCount = dataHabit.habitRecords.count
            if habitRecordCount >= maxRecords {
                maxRecords = habitRecordCount
                maxHabit = dataHabit
            }
        }
        
        guard let maxHabit else { return nil }
        return (maxRecords, maxHabit)
    }
    
    
    private var bestStreak: (habit: DataHabit, streakCount: Int)? {
        
        let bestStreakHabits: [DataHabit] = Array(bestStreaks.keys)
        var maxStreakCount = 0
        var maxStreakHabit: DataHabit?
        
        for bestStreakHabit in bestStreakHabits {
            let habitStreak = bestStreaks[bestStreakHabit] ?? 0
            
            if habitStreak > maxStreakCount {
                maxStreakCount = habitStreak
                maxStreakHabit = bestStreakHabit
            }
        }
        
        guard let maxStreakHabit else { return nil }
        return (maxStreakHabit, maxStreakCount)
    }
    
    @State private var totalDays = 0
    @State private var bestStreaks = [DataHabit: Int]()
    
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView {
            
                
                let screenHeight = proxy.size.height
                let graphHeight = screenHeight * 0.3

                StatisticsBarView(
                    graphHeight: graphHeight,
                    numOfItemsToReachTop: 12,
                    datesWithHabitRecords: datesWithHabitRecords
                )
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    if !selectableHabits.isEmpty {
                        LazyHStack {
                            ForEach($selectableHabits, id: \.self) { selectableHabit in
                                Button {
                                    print("tapped selectableHabit")
                                    selectableHabit.wrappedValue.isSelected.toggle()
                                } label: {
                                    Text("\(selectableHabit.wrappedValue.habit.name)")
                                }
                            }
                        }
                        Button("Reset") {
                            print("Tapped Reset")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow)
                        .padding(.horizontal)
                    }
                }
                
                
                Grid(alignment: .topLeading) {
                    
                    GridRow {
                        StatBox(title: "Total Records", value: "\(totalRecords)")
                        StatBox(title: "Total Days", value: "\(totalDays)")
                        StatBox(title: "Avg Records / Day", value: String(format: "%.2f", avgRecordsPerDay), units: "rpd")
                            .gridCellColumns(2)
                    }
                    GridRow {
                        if let mostCompletions {
                            StatBox(title: "Most Completions", value: "\(mostCompletions.recordCount)", units: "records", subValue: "\(mostCompletions.habit.name)", subValueColor: Color(hex: mostCompletions.habit.color))
                                .gridCellColumns(2)
                        } else {
                            StatBox(title: "Most Completions", value: "N/A")
                                .gridCellColumns(2)
                        }
                            
                        
                        if let bestStreak {
                            StatBox(title: "Best Streak", value: "\(bestStreak.streakCount)", units: "days", subValue: "\(bestStreak.habit.name)", subValueColor: Color(hex: bestStreak.habit.color))
                                .gridCellColumns(2)
                        } else {
                            StatBox(title: "Best Streak", value: "N/A")
                                .gridCellColumns(2)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
//        .padding(.horizontal)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateDatesWithHabitRecords()
        }
    }
    
    
    /// Populate` datesWithHabitRecords`
    private func calculateDatesWithHabitRecords() {
        
        let calendar = Calendar.current
        
        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon,
              let today = Date().noon,
              let days = calendar.dateComponents([.day], from: startOf2024, to: today).day
        else { return }
        
        var dict = [Date: [DataHabitRecord]]()
        
        // average records / day
        /*
         * NOTE: This is being calculated for only the days that the record is done.
         * I think it would be demoralizing to see if you fell off and were trying to get back on
         */
        var daysRecordHasBeenDone = 0
        var recordsThatHaveBeenDone = 0
        
        // We want to have all habits that exist here so that we can easily test their streak values
        var habitStreaks: [DataHabit: Int] = Dictionary(uniqueKeysWithValues: dataHabits.map {($0, 0)} )
        var habitBestStreaks: [DataHabit: Int] = Dictionary(uniqueKeysWithValues: dataHabits.map {($0, 0)} )
        
        
        for record in dataHabitRecords {
            
            guard let noonDate = record.completionDate.noon else { return }
            if dict[noonDate] != nil {
                dict[noonDate]?.append(record)
            } else {
                dict[noonDate] = [record]
            }
        }
        
        totalDays = dict.keys.count
        
        // Maybe for now, lets just start at january 1, 2024 for the beginning.
        for day in 0...days {
            // We want to get noon so that everything is definitely the exact same date (and we inserted the record dictinoary keys by noon)
            guard let noonDate = calendar.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return }
            
            if let habitRecordsForDate = dict[noonDate] {
                
                datesWithHabitRecords[noonDate] = habitRecordsForDate
                
                daysRecordHasBeenDone += 1
                recordsThatHaveBeenDone += habitRecordsForDate.count
                
                // Best Streak logic
                let uniqueHabitsForTheDay = Set(habitRecordsForDate.map { $0.habit })
               
                for habit in dataHabits {
                    if uniqueHabitsForTheDay.contains(habit) {
                        // The bang operator should be fine because of my initialization of this dictionary
                        habitStreaks[habit]! += 1
                    } else {
                        let bestStreakForHabit = habitBestStreaks[habit] ?? 0
                        let endedStreakForHabit = habitStreaks[habit] ?? 0
                        if bestStreakForHabit < endedStreakForHabit {
                            habitBestStreaks[habit] = endedStreakForHabit
                        }
                        habitStreaks[habit] = 0
                    }
                }
            } else {
                datesWithHabitRecords[noonDate] = []
                
                // If there is nothing for this day, all streaks should be zeroed out
                for habit in dataHabits {
                    
                    let bestStreakForHabit = habitBestStreaks[habit] ?? 0
                    let endedStreakForHabit = habitStreaks[habit] ?? 0
                    
                    if bestStreakForHabit < endedStreakForHabit {
                        habitBestStreaks[habit] = endedStreakForHabit
                    }
                    
                    habitStreaks[habit] = 0
                }
            }
        }
        
        // We do this again because we want to ensure that the last day is counted in the current max,
        // We don't need to zero out the streak in this case, but it doesn't matter either way
        for habit in dataHabits {
            
            let bestStreakForHabit = habitBestStreaks[habit] ?? 0
            let endedStreakForHabit = habitStreaks[habit] ?? 0
            
            if bestStreakForHabit < endedStreakForHabit {
                habitBestStreaks[habit] = endedStreakForHabit
            }
        }
        
        bestStreaks = habitBestStreaks
    }
//
//    private func filterButton(habit: DataHabit) -> some View {
//        
//        Button {
//            
//        } label: {
//            
//        }
//    }
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
    let dataHabit2 = DataHabit(
        id: UUID().uuidString,
        name: "Smashed Taco",
        color: Habit.habits[1].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    container.mainContext.insert(dataHabit2)
    
    let dataHabitRecord = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit
    )
    let dataHabitRecord2 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit
    )
    let dataHabitRecord3 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord)
    container.mainContext.insert(dataHabitRecord2)
    container.mainContext.insert(dataHabitRecord3)
    
    
    let dataHabitRecord21 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: 0),
        habit: dataHabit2
    )
    let dataHabitRecord22 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit2
    )
    let dataHabitRecord23 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit2
    )
    let dataHabitRecord24 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit2
    )
    
    container.mainContext.insert(dataHabitRecord21)
    container.mainContext.insert(dataHabitRecord22)
    container.mainContext.insert(dataHabitRecord23)
    container.mainContext.insert(dataHabitRecord24)
    
    
    
    
    return NavigationStack {
        StatisticsView()
    }
    .modelContainer(container)
}
