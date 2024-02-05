//
//  HomeView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import SwiftData


enum HabitRecordVisualMode {
    case bar
    case daily
}


protocol ActivityRecordCreator {
    
    var selectedDay: Date { get set }
    var goToCreateActivityRecordWithDetails: (DataHabit, Date) -> Void { get }
}


extension ActivityRecordCreator {
    
    func createRecord(for activity: DataHabit, in modelContext: ModelContext) {
        
        if !activity.activityDetails.isEmpty {
            
            goToCreateActivityRecordWithDetails(activity, selectedDay)
            
        } else {
            
            let (creationDate, completionDate) = ActivityRecordCreationPolicy.calculateDatesForRecord(on: selectedDay)
            
            modelContext.createHabitRecordOnDate(activity: activity, creationDate: creationDate, completionDate: completionDate)
        }
    }
}


struct HomeView: View, ActivityRecordCreator {
    
    @Environment(\.modelContext) var modelContext
    @Query var dataHabits: [DataHabit]
    @Query(sort: [
        SortDescriptor(\DataHabitRecord.completionDate, order: .reverse),
        SortDescriptor(\DataHabitRecord.creationDate, order: .reverse)
    ], animation: .default) var dataHabitRecords: [DataHabitRecord]
    
    
    let goToHabitDetail: (DataHabit) -> Void
    let goToCreateHabit: () -> Void
    let goToHabitRecordDetail: (DataHabitRecord) -> Void
    let goToEditHabit: (DataHabit) -> Void
    let goToStatistics: () -> Void
    let goToCreateActivityRecordWithDetails: (DataHabit, Date) -> Void
    
    /*
     * So now the goal is to setup all of the data record stuff here from SwiftData.
     * The big problem is habitsOnDates is a little bit hairy. I wonder if it is better
     * for me to be able to query all of the datahabits and then deliver them to the
     * bar graphs... or maybe I should just decipher it here. This will be everything I should
     * have so I think it should be fine.
     */
    
    @State private var habitRecordVisualMode: HabitRecordVisualMode = .bar
    @State var selectedDay: Date = Date().noon!
    
    
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
        
        
            print("received from habitRepository fetch... \(dataHabitRecords.count)")
//
            // Convert to a dictionary in order for us to an easier time in searching for dates
            var dict = [Date: [DataHabitRecord]]()
            
            for record in dataHabitRecords {
                
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
                    _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habitsRecords: habitRecordsForDate))
                } else {
                    _dataHabitRecordsOnDate.append(DataHabitRecordsOnDate(funDate: noonDate, habitsRecords: []))
                }
            }
            
            return _dataHabitRecordsOnDate
    }


    var body: some View {
        
        let _ = print("issa sqlite: \(modelContext.sqliteCommand)")
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
//            let safeAreaInsetTop = proxy.safeAreaInsets.top
            let graphHeight = screenHeight * 0.4
//            let habitMenuHeight = screenHeight * 0.3
//            let itemHeight = graphHeight / 8
            
            VStack {
                switch habitRecordVisualMode {
                case .bar:
                    BarView(graphWidth: screenWidth, graphHeight: graphHeight, numOfItemsToReachTop: 8, dataHabitRecordsOnDate: dataHabitRecordsOnDate, selectedDay: $selectedDay)
                case .daily:
                    DayView(
                        goToHabitRecordDetail: goToHabitRecordDetail,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 8,
                        habitRecords: dataHabitRecordsForSelectedDay,
                        selectedDay: selectedDay
                    )
                }
                
                HabitsMenu(
                    goToHabitDetail: goToHabitDetail,
                    goToEditHabit: goToEditHabit,
                    habits: dataHabits,
                    didTapCreateHabitButton: {
                        goToCreateHabit()
                    }, didTapHabitButton: { habit in
                        createRecord(for: habit, in: modelContext)
                    }
                )
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button {
                        goToPreviousDay()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                    .disabled(isAllowedToGoToPreviousDay ? false : true)
                    
                    Text(displaySelectedDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button {
                        goToNextDay()
                    } label: {
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                    }
                    .disabled(isAllowedToGoToNextDay ? false : true)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    goToStatistics()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                }
                
                // TODO: Some logic to dictate whether it is a bar button or a daily log button
                switch habitRecordVisualMode {
                case .bar:
                    // Daily button
                    Button {
                        setHabitRecordViewMode(to: .daily)
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .fontWeight(.semibold)
                    }
                case .daily:
                    // Chart button
                    Button {
                        setHabitRecordViewMode(to: .bar)
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
//    
//    private func logRecord(for habit: DataHabit) {
//        
//        if !habit.activityDetails.isEmpty {
//            
//            goToCreateActivityRecordWithDetails(habit, selectedDay)
//            
//        } else {
//            
//            let (creationDate, completionDate) = ActivityRecordCreationPolicy.calculateDatesForRecord(on: selectedDay)
//            
//            modelContext.createHabitRecordOnDate(activity: habit, creationDate: creationDate, completionDate: completionDate)
//        }
//    }

    
    private func setHabitRecordViewMode(to visualMode: HabitRecordVisualMode) {
        
        withAnimation(.easeOut) {
            habitRecordVisualMode = visualMode
        }
    }
    
    
    private var dataHabitRecordsForSelectedDay: [DataHabitRecord] {
        
        guard let dataHabitRecordsSelectedForDay = dataHabitRecordsOnDate.filter({ $0.funDate == selectedDay }).first?.habitsRecords else {
            return []
        }
        
        return dataHabitRecordsSelectedForDay
    }
    
    
    private var displaySelectedDate: String {
        let formatter: DateFormatter = .shortDate
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        let twoDaysAgo = Date().noon!.adding(days: -2)
        let threeDaysAgo = Date().noon!.adding(days: -3)
        let fourDaysAgo = Date().noon!.adding(days: -4)
        
        switch selectedDay {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        case twoDaysAgo:
            return "2 Days Ago"
        case threeDaysAgo:
            return "3 Days Ago"
        case fourDaysAgo:
            return "4 Days Ago"
        default:
            return formatter.string(from: selectedDay)
        }
    }
    
    
    private func goToNextDay() {
        
        if isAllowedToGoToNextDay {
            selectedDay = selectedDay.adding(days: 1)
        }
    }
    
    
    private var isAllowedToGoToNextDay: Bool {

        guard let today = Date().noon else { return false }
        return selectedDay != today ? true : false
    }
    
    
    private func goToPreviousDay() {
        
        if isAllowedToGoToPreviousDay {
            selectedDay = selectedDay.adding(days: -1)
        }
    }
    
    
    private var isAllowedToGoToPreviousDay: Bool {
        
        let calendar = Calendar.current
        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon else { return false }
        
        return selectedDay != startOf2024 ? true : false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugged Dew",
        color: Habit.habits[0].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    let dataHabit2 = DataHabit(
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
    
    
    let habit = Habit.meditation
    return NavigationStack {
        HomeView(
            goToHabitDetail: { _ in },
            goToCreateHabit: { },
            goToHabitRecordDetail: { _ in },
            goToEditHabit: { _ in },
            goToStatistics: { },
            goToCreateActivityRecordWithDetails: { _, _ in }
        )
        .modelContainer(container)
    }
}
