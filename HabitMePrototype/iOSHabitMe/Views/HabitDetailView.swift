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
    @State private var selectedDay: Date = Date().noon ?? Date()
//     Query to fetch all of the habit records for the habit
    @Query var dataHabitRecordsForHabit: [DataHabitRecord]
    
    
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
                    _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habits: habitRecordsForDate))
                } else {
                    _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habits: []))
                }
            }
            
            return _dataHabitRecordsOnDate
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
                    numOfItemsToReachTop: 5,
                    dataHabitRecordsOnDate:
                        dataHabitRecordsOnDate,
                    selectedDay: $selectedDay
                )
                
                HabitMePrimaryButton(title: "Log New Record", color: Color(hex: habit.color)) {
                    print("create habit record")
                }
                .padding()
                
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .navigationTitle("Habit Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let habit = Habit.meditation
    return NavigationStack {
        HabitDetailView(habit: DataHabit(id: UUID().uuidString, name: habit.name, color: habit.color.toHexString() ?? "#FFFFFF", habitRecords: []))
    }
}
