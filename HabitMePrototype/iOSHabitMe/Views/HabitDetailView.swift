//
//  HabitDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/23/24.
//

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    
    
    let habit: DataHabit
    // Keeping a separate selectedDay here so that it does not impact the home screen when
    // this is dismissed
    @Environment(\.modelContext) var modelContext
    @State private var selectedDay: Date = Date().noon ?? Date()
//     Query to fetch all of the habit records for the habit
    @Query var dataHabitRecordsForHabit: [DataHabitRecord]
    
    @State private var currentStreak = 0
    @State private var avgRecordsPerDay: Double = 0
    @State private var bestStreak = 0
    
    let numOfItemsToReachTop = 5
    
    var dataHabitRecordsOnDate: [DataHabitRecordsOnDate] {
        
        var _dataHabitRecordsOnDate = [DataHabitRecordsOnDate]()
        
        print("update habit records by loading them")
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        calendar.locale = .current
        
        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon,
              let today = Date().noon,
              let days = calendar.dateComponents([.day], from: startOf2024, to: today).day
        else { return [] }
        
        
        print("received from habitRepository fetch... \(dataHabitRecordsForHabit.count)")
        //
        // Convert to a dictionary in order for us to an easier time in searching for dates
        var dict = [Date: [DataHabitRecord]]()
        // It is ordered from first date (jan. 1st) -> last date (today), the key is the last date in the streak
        var streakingCount = 0
        var lastStreakCount = 0
        var maxStreakCount = 0
        
        // average records / day
        /*
         * NOTE: This is being calculated for only the days that the record is done.
         * I think it would be demoralizing to see if you fell off and were trying to get back on
         */
        var daysRecordHasBeenDone = 0
        var recordsThatHaveBeenDone = 0
        
        
        for record in dataHabitRecordsForHabit {
            
            guard let noonDate = record.completionDate.noon else { return [] }
            if dict[noonDate] != nil {
                dict[noonDate]?.append(record)
            } else {
                dict[noonDate] = [record]
            }
        }
        
        
        // Maybe for now, lets just start at january 1, 2024 for the beginning.
        for day in 0...days {
            // We want to get noon so that everything is definitely the exact same date (and we inserted the record dictinoary keys by noon)
            guard let noonDate = calendar.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return [] }
            
            if let habitRecordsForDate = dict[noonDate] {
                // graph logic
                _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habits: habitRecordsForDate))
                
                daysRecordHasBeenDone += 1
                recordsThatHaveBeenDone += habitRecordsForDate.count
                
                // streak logic
                streakingCount += 1
                
            } else {
                _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habits: []))
                
                // streak logic
                if streakingCount >= maxStreakCount {
                    maxStreakCount = streakingCount
                }
                lastStreakCount = streakingCount
                streakingCount = 0
            }
        }
        
        // streak logic
        if streakingCount > 0 {
            // Streak has continued to today
            if streakingCount >= maxStreakCount {
                maxStreakCount = streakingCount
            }
            lastStreakCount = streakingCount
        }
        
        DispatchQueue.main.async {
            currentStreak = lastStreakCount
            avgRecordsPerDay = Double(recordsThatHaveBeenDone) / Double(daysRecordHasBeenDone)
            bestStreak = maxStreakCount
        }
        
        
        return _dataHabitRecordsOnDate
    }
    
    
    var totalRecords: String {
        return "\(dataHabitRecordsForHabit.count)"
    }
    
    
    init(habit: DataHabit) {
        
        self.habit = habit
        
        let habitID = habit.id
        
        _dataHabitRecordsForHabit = Query(
            filter: #Predicate {
                $0.habit.id == habitID
            }, sort: [
                SortDescriptor(\DataHabitRecord.completionDate, order: .reverse),
                SortDescriptor(\DataHabitRecord.creationDate, order: .reverse)
            ], animation: .default
        )
    }
    
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let graphHeight = screenHeight * 0.3

            VStack(spacing: 0) {
                BarView(
                    graphWidth: screenWidth,
                    graphHeight: graphHeight,
                    numOfItemsToReachTop: Double(numOfItemsToReachTop),
                    dataHabitRecordsOnDate:
                        dataHabitRecordsOnDate,
                    selectedDay: $selectedDay
                )
                
                HabitMePrimaryButton(title: "Log New Record", color: Color(hex: habit.color)) {
                    SwiftDataHabitRepository.shared.createHabitRecordOnDate(habit: habit, selectedDay: selectedDay, modelContext: modelContext)
                }
                .padding()
                
                Grid() {
                    GridRow {
                        totalRecordsStatBox(totalRecords: totalRecords)
                        currentStreakStatBox(currentStreak: currentStreak)
                    }
                    GridRow {
                        avgRecordsPerDayStatBox(avgRecordsPerDay: avgRecordsPerDay)
                        bestStreakStatBox(bestStreak: bestStreak)
                    }
                }
                .padding()
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10)
                 )
                .padding([.horizontal, .bottom])
                
//                DayView(
//                    graphHeight: 150,
//                    numOfItemsToReachTop: numOfItemsToReachTop,
//                    habitRecords: dataHabitRecordsForHabit,
//                    selectedDay: selectedDay
//                )
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .navigationTitle("\(habit.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    func totalRecordsStatBox(totalRecords: String) -> some View {
        statBox(title: "Total Records", value: totalRecords)
    }

    func currentStreakStatBox(currentStreak: Int) -> some View {
        
        if currentStreak == 1 {
            statBox(title: "Current Streak", value: "\(currentStreak)", units: "day")
        } else {
            statBox(title: "Current Streak", value: "\(currentStreak)", units: "days")
        }
    }
    
    func avgRecordsPerDayStatBox(avgRecordsPerDay: Double) -> some View {
        let title = "Average Records / Day"
        if avgRecordsPerDay > 0 {
            return statBox(title: title, value: String(format: "%.2f", avgRecordsPerDay), units: "rpd")
        } else {
            return statBox(title: title, value: "N/A")
        }

    }
    
    func bestStreakStatBox(bestStreak: Int) -> some View {
        if bestStreak == 1 {
            return statBox(title: "Best Streak", value: "\(bestStreak)", units: "day")
        } else {
            return statBox(title: "Best Streak", value: "\(bestStreak)", units: "days")
        }
    }
    
    
    func statBox(title: String, value: String, units: String? = nil) -> some View {
        
        VStack(spacing: 0) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.center)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                if let units {
                    Text(units)
                        .font(.callout)
                }
            }
        }
        .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 10))
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
    

    let dataHabitRecord0 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: 0),
        habit: dataHabit
    )
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

    container.mainContext.insert(dataHabitRecord0)
    container.mainContext.insert(dataHabitRecord)
    container.mainContext.insert(dataHabitRecord2)
    container.mainContext.insert(dataHabitRecord3)
    
    
    let dataHabitRecord4 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -8),
        habit: dataHabit
    )
    let dataHabitRecord5 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -9),
        habit: dataHabit
    )
    let dataHabitRecord6 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -10),
        habit: dataHabit
    )
    let dataHabitRecord7 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -11),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord4)
    container.mainContext.insert(dataHabitRecord5)
    container.mainContext.insert(dataHabitRecord6)
    container.mainContext.insert(dataHabitRecord7)
    
    let habit = Habit.meditation
    return NavigationStack {
        HabitDetailView(habit: dataHabit)
        .modelContainer(container)
    }
}
