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

struct SelectableHabit: Hashable, SelectableListItem {

    let id: String
    let name: String
    var isSelected: Bool = true
    var colorString: String?
    
    // This is kept for easily keeping data that will be needed later
    var habit: DataHabit
    
    init(habit: DataHabit) {
        self.id = habit.id
        self.name = habit.name
        self.colorString = habit.color 
        self.habit = habit
    }
}

struct StatisticsView: View {
    
    @Query(sort: [
        SortDescriptor(\DataHabitRecord.completionDate, order: .reverse),
        SortDescriptor(\DataHabitRecord.creationDate, order: .reverse)
    ], animation: .default) var dataHabitRecords: [DataHabitRecord]
    
    @Query var dataHabits: [DataHabit]
    /// We are filtering on the habits that are selectable (which are built from the dataHabits query - other than setting up the selectableHabits, `dataHabits` should never be used
    private var selectedHabits: [DataHabit] { 
        let allSelectedHabits = selectableHabits.filter { $0.isSelected }.map { $0.habit }
        return allSelectedHabits
    }
    
//    private var selectedHabitRecords: [DataHabitRecord] { }
    @State private var selectableHabits = [SelectableHabit]()
    @State private var selectedHabitRecords = [DataHabitRecord]()
    @State private var datesWithHabitRecords = [Date: [DataHabitRecord]]()
    private var selectedDay = Date() // This is just for scrolling to the end of the chart
    
    // Basic stats
    private var totalRecords: Int { selectedHabitRecords.count }
    
    private var avgRecordsPerDay: Double {
        
        guard totalDays != 0 else { return 0 }
        return Double(totalRecords)/Double(totalDays)
    }
    
    private var mostCompletions: (recordCount: Int, habit: DataHabit)? {
        var maxRecords = 0
        var maxHabit: DataHabit?
        
        for dataHabit in selectedHabits {
            let habitRecordCount = dataHabit.habitRecords.count
            if habitRecordCount > maxRecords {
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
            
                let screenWidth = proxy.size.width
                let screenHeight = proxy.size.height
                let graphHeight = screenHeight * 0.3

                VStack(spacing: 0) {
                    // FIXME: Statistics is broken until further notice
//                    StatisticsBarView(
//                        graphWidth: screenWidth,
//                        graphHeight: graphHeight,
//                        numOfItemsToReachTop: 12,
//                        datesWithHabitRecords: datesWithHabitRecords
//                    )
//                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if !selectableHabits.isEmpty {
                            HStack {
                                Text("Habits")
                                    .font(.title3)
                                
                                Spacer()
                                
                                Button("Reset") {
                                    for i in 0..<selectableHabits.count {
                                        selectableHabits[i].isSelected = true
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            
                            HorizontalScrollySelectableList(items: $selectableHabits)
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
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupSelectableHabits()
            calculateDatesWithHabitRecords()
        }
        .onChange(of: selectedHabits) {
            selectedHabitRecords = dataHabitRecords.filter { habitRecord in
                guard let habitForHabitRecord = habitRecord.habit else { return false }
                return selectedHabits.contains(habitForHabitRecord)
            }
            
            calculateDatesWithHabitRecords()
        }
    }
    
    
    private func setupSelectableHabits() {
        
        print("setup for selectable habits happens")
        selectableHabits = dataHabits.map { SelectableHabit(habit: $0) }
        
        selectedHabitRecords = dataHabitRecords.filter { habitRecord in
            guard let habitForHabitRecord = habitRecord.habit else { return false }
            return selectedHabits.contains(habitForHabitRecord)
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
        var habitStreaks: [DataHabit: Int] = Dictionary(uniqueKeysWithValues: selectedHabits.map {($0, 0)} )
        var habitBestStreaks: [DataHabit: Int] = Dictionary(uniqueKeysWithValues: selectedHabits.map {($0, 0)} )
        
        // Only track the selected habit records
        for record in selectedHabitRecords {
            
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
               
                for habit in selectedHabits {
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
                for habit in selectedHabits {
                    
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
        for habit in selectedHabits {
            
            let bestStreakForHabit = habitBestStreaks[habit] ?? 0
            let endedStreakForHabit = habitStreaks[habit] ?? 0
            
            if bestStreakForHabit < endedStreakForHabit {
                habitBestStreaks[habit] = endedStreakForHabit
            }
        }
        
        bestStreaks = habitBestStreaks
    }
}


// Needs to be Identifiable for the foreach conformance, just makes it easier
protocol SelectableListItem: Identifiable {
    
    var id: String { get } // Id stays the same
    var name: String { get } // Name stays the same
    var isSelected: Bool { get set } // Gets toggled
    
    var colorString: String? { get }
}


extension SelectableListItem {
    
    var color: Color {
        
        let defaultColor = Color.blue
        
        guard let colorString, let unwrappedColor = Color(hex: colorString) else {
            return defaultColor
        }
        
        return unwrappedColor
    }
}


struct HorizontalScrollySelectableList<T: SelectableListItem>: View {
    
    @Binding var items: [T]
    
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<items.count, id: \.self) { i in
                    
                    let item = items[i]
                    let isSelected = item.isSelected
                    let name = item.name
                    let color = item.color
                    
                    Button {
                        print("tapped selectableHabit")
                        withAnimation {
                            items[i].isSelected.toggle()
                        }
                    } label: {
                        Text("\(name)")
                            .foregroundStyle(Color.primary)
                    }
                    .padding(8)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? color : .clear)
                            .stroke(isSelected ? Color.clear : color, lineWidth: 3)
                    )
                    .padding(.vertical)
                }
            }
            .padding(.leading)
        }
    }
}


#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugged Dew",
        isArchived: false,
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    let dataHabit2 = DataHabit(
        name: "Smashed Taco",
        isArchived: false,
        color: Color.orange.toHexString() ?? "#FFFFFF",
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
