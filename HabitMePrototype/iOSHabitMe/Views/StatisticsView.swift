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
    @State private var selectedDay = Date()
    
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView {
            
                
                let screenHeight = proxy.size.height
                let graphHeight = screenHeight * 0.3
                
//                BarView(
//                    graphWidth: screenWidth,
//                    graphHeight: graphHeight,
//                    numOfItemsToReachTop: Double(numOfItemsToReachTop),
//                    dataHabitRecordsOnDate:
//                        dataHabitRecordsOnDate,
//                    selectedDay: $selectedDay
//                )
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
                        StatBox(title: "Total Records", value: "150")
                        StatBox(title: "Average Records / Day", value: "9.2", units: "rpd")
                    }
                    GridRow {
                        StatBox(title: "Most Completions", value: "42", units: "records", subValue: "Journaling")
                        StatBox(title: "Best Streak", value: "10", units: "days", subValue: "Meditation")
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
        
        for record in dataHabitRecords {
            
            guard let noonDate = record.completionDate.noon else { return }
            if dict[noonDate] != nil {
                dict[noonDate]?.append(record)
            } else {
                dict[noonDate] = [record]
            }
        }
        
        // Maybe for now, lets just start at january 1, 2024 for the beginning.
        for day in 0...days {
            // We want to get noon so that everything is definitely the exact same date (and we inserted the record dictinoary keys by noon)
            guard let noonDate = calendar.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return }
            
            if let habitRecordsForDate = dict[noonDate] {
                datesWithHabitRecords[noonDate] = habitRecordsForDate
            } else {
                datesWithHabitRecords[noonDate] = []
            }
        }
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
}
