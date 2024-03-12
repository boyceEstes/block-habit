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


//struct ActivityMenuFilter: SelectableListItem {
//    
//    let activityMenuFilterType: ActivityMenuFilterType
//    var isSelected: Bool
//    
//    
//    var id: String {
//        name
//    }
//
//    var name: String {
//        activityMenuFilterType.name
//    }
//}


//extension DataHabit {
//    
//    func isActivityComplete(activityRecords: [DataHabitRecord]) -> Bool {
//        
//        if let completionGoal = goalCompletionsPerDay {
//            let recordCountForHabit = activityRecords.reduce(0) { partialResult, activityRecord in
//                if activityRecord.habit == self { return partialResult + 1 }
//                else { return partialResult }
//            }
//            
//            return recordCountForHabit >= completionGoal
//        } else {
//            // It can never be complete
//            return false
//        }
//    }
//}


struct HomeView: View, ActivityRecordCreatorOrNavigator {
    
    @Environment(\.modelContext) var modelContext
    @Query var dataHabits: [DataHabit]
//    @Query(sort: [
//        SortDescriptor(\DataActivityFilter.order, order: .forward)
//    ]) var activityFilterOptions: [DataActivityFilter]
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
    
//    // Filtering activity menu
//    @State private var isActivityFilterMenuShowing = false
////    @State private var activityFilterOptions = ActivityMenuFilterType.allCases.map { ActivityMenuFilter(activityMenuFilterType: $0, isSelected: true) }
//    
//    var isActivityMenuFiltered: Bool {
//        // if there is a single false isSelected, we should make this button filled
//        activityFilterOptions.contains { activityMenuFilter in
//            return activityMenuFilter.isSelected == false
//        }
//    }
//    
//    var allowedActivityFilters: [DataActivityFilter] {
//        print("Activity: Changed the allowed activityfilteroptions")
//        return activityFilterOptions.filter { $0.isSelected }
//    }
//    
//    var filteredActivities: [DataHabit] {
//        
//        // If there is nothing filtered we just return everything
//        guard isActivityMenuFiltered else { return
//            dataHabits
//        }
//        
//        return dataHabits.filter { activity in
//            
//            // FIXME: This is atrociously ugly but it might work for now at the cost of performance
//            var dateActivityRecordDict = [Date: [DataHabitRecord]]()
//            for record in dataHabitRecords {
//                
//                guard let noonDate = record.completionDate.noon else { return false }
//                
//                if dateActivityRecordDict[noonDate] != nil {
//                    dateActivityRecordDict[noonDate]?.append(record)
//                } else {
//                    dateActivityRecordDict[noonDate] = [record]
//                }
//            }
//        
//            guard let selectedDayNoon = selectedDay.noon,
//                  let recordsForSelectedDay = dateActivityRecordDict[selectedDayNoon] else { return true }
//            
//            let isActivityCompleted = activity.isActivityComplete(activityRecords: recordsForSelectedDay)
//            
////            let allowedActivityFilters = activityFilterOptions.filter { $0.isSelected }
//            var isAllowed = false
//            if isActivityCompleted {
//                isAllowed = allowedActivityFilters.contains { $0.filterType == .complete }
//            } else {
//                isAllowed = allowedActivityFilters.contains { $0.filterType == .incomplete }
//            }
//            
//            guard isAllowed != false else { return false } // Don't continue if we already know its not allowed
//            
//            // If there are later conditions add them here
//            print("Activity: \(activity.name) - isAllowed: \(isAllowed), isActivityCompleted: '\(isActivityCompleted)'")
//            return isAllowed
//        }
//    }

    
    var datesWithHabitRecords: [Date: [DataHabitRecord]] {
        
        var _datesWithHabitRecords = [Date: [DataHabitRecord]]()
        
        print("update habit records by loading them")
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        calendar.locale = .current
        
        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon,
              let today = Date().noon,
              let days = calendar.dateComponents([.day], from: startOf2024, to: today).day
        else { return [:] }
        
        
            print("received from habitRepository fetch... \(dataHabitRecords.count)")
//
            // Convert to a dictionary in order for us to an easier time in searching for dates
            var dateActivityRecordDict = [Date: [DataHabitRecord]]()
        
            for record in dataHabitRecords {
                
                guard let noonDate = record.completionDate.noon else { return [:] }
                
                if dateActivityRecordDict[noonDate] != nil {
                    dateActivityRecordDict[noonDate]?.append(record)
                } else {
                    dateActivityRecordDict[noonDate] = [record]
                }
            }

            
            // Maybe for now, lets just start at january 1, 2024 for the beginning.
            for day in 0...days {
                // We want to get noon so that everything is definitely the exact same date (and we inserted the record dictinoary keys by noon)
                guard let noonDate = calendar.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return [:] }
                
                
                if let habitRecordsForDate = dateActivityRecordDict[noonDate] {
                    _datesWithHabitRecords[noonDate] = habitRecordsForDate
                } else {
                    _datesWithHabitRecords[noonDate] = []
                }
            }
            
            return _datesWithHabitRecords
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
                    BarView(graphWidth: screenWidth, graphHeight: graphHeight, numOfItemsToReachTop: 8, datesWithHabitRecords: datesWithHabitRecords, selectedDay: $selectedDay)
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
                    habits: dataHabits/*filteredActivities*/,
                    didTapCreateHabitButton: {
                        goToCreateHabit()
                    }, didTapHabitButton: { habit in
                        createRecord(for: habit, in: modelContext)
                    }
                )
                
//                VStack(spacing: .vSectionSpacing) {
//                    
//                    VStack(alignment: .leading, spacing: .vItemSpacing) {
//                        HStack {
//                            Text("Habits")
//                            Spacer()
//                            HStack(spacing: 16) {
////                                Button {
////                                    withAnimation {
////                                        isActivityFilterMenuShowing.toggle()
////                                    }
////                                } label: {
////                                    
////                                    Image(systemName: isActivityMenuFiltered ?  "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
////                                }
//                                Button {
//                                    goToCreateHabit()
//                                } label: {
//                                    Image(systemName: "plus.circle")
//                                }
//                            }
//                        }
//                        .homeDetailTitle()
//                        
////                        if isActivityFilterMenuShowing {
////                            
////                            // Binding is necessary to work with the reusable component and keep everything separated
////                            let activityFitlerOptionsBinding = Binding {
////                                activityFilterOptions
////                            } set: { newActivityFilterOptions in
////                                
////                                // There should never be a change in the array size or order
////                                let activityFilterOptionsCount = activityFilterOptions.count
////                                
////                                guard activityFilterOptionsCount == newActivityFilterOptions.count else {
////                                    print("Log: Somehow the arrays are off")
////                                    return
////                                }
////                                
////                                // Set each element of the array to the new element
////                                // - there can be multiple set if you toggle "All"
////                                for index in 0..<activityFilterOptionsCount {
////                                    activityFilterOptions[index].isSelected = newActivityFilterOptions[index].isSelected
////                                }
////                            }
////                            
////                            HorizontalScrollySelectableList(items: activityFitlerOptionsBinding)
////                        }
//                    }
//                }
//                .sectionBackground()
//                .padding()
            }
            .background(Color.primaryBackground)
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
        
        guard let dataHabitRecordsSelectedForDay = datesWithHabitRecords[selectedDay] else {
            return []
        }
//        guard let dataHabitRecordsSelectedForDay = dataHabitRecordsOnDate.filter({ $0.funDate == selectedDay }).first?.habitsRecords else {
//            return []
//        }
        
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
        color: Color.blue.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    let dataHabit2 = DataHabit(
        name: "Smashed Taco",
        color: Color.orange.toHexString() ?? "#FFFFFF",
//        goalCompletionsPerDay: 1,
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
