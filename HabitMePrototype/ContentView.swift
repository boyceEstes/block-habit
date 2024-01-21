//
//  ContentView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI


enum SpecialHabitError: Error {
    
}

protocol HabitRepository {
    
    typealias FetchAllHabitRecordsResult = [HabitRecord]
    typealias InsertNewHabitRecordResult = SpecialHabitError?
    
    func fetchAllHabitRecords(completion: (FetchAllHabitRecordsResult) -> Void)
    func insertNewHabitRecord(_ habitRecord: HabitRecord, completion: (InsertNewHabitRecordResult) -> Void)
}


class InMemoryHabitRepository: HabitRepository {
    
    // We'll init it with some demo data
    private var habitRecords = HabitRecord.habitRecords {
        didSet {
            print("Updated habit records...")
            print(habitRecords)
        }
    }
    
    
    func fetchAllHabitRecords(completion: (FetchAllHabitRecordsResult) -> Void) {
        
        print("fetching... \(habitRecords.count)")
        completion(habitRecords)
    }
    
    
    func insertNewHabitRecord(_ habitRecord: HabitRecord, completion: (InsertNewHabitRecordResult) -> Void) {
        
        print("Adding Habit Record: \(habitRecord.habit.name) ")
        habitRecords.append(habitRecord)
        
        completion(nil)
    }
}


struct Habit: Hashable {

    let name: String
    let color: Color
    
    static let meditation = Habit(name: "Meditation", color: .orange)
    static let journal = Habit(name: "Journal", color: .blue)
    static let reading = Habit(name: "Reading", color: .cyan)
    static let walkTheCat = Habit(name: "Walk the Cat", color: .green)
    
    static let habits = [
        meditation,
        journal,
        reading,
        walkTheCat
    ]
}


struct HabitRecord: Hashable {
    
    // Creation date is for those times that we will have selected a past day and added a habit record
    // to it. We will be adding it at the last possible hour/minute of the day so that it populates at
    // the end, but if we do two of those, we want to order by the one that was created latest.
    let creationDate: Date
    let completionDate: Date
    let habit: Habit
    
    static let habitRecords = [
        // Meditation logs
        // 16
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 9).date!,
            habit: Habit.journal
        ),
        // 17
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 10).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 17).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 17).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 18).date!,
            habit: Habit.meditation
        ),
        // 18
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 10).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 14).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 14).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 15).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 15).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 16).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 16).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 17).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 17).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:  DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 23).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 23).date!,
            habit: Habit.journal
        ),
        // 19
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 19).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            habit: Habit.meditation
        ),
        // 20
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 19).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            habit: Habit.reading
        )
    ]
}


struct HabitsOnDate: Hashable {
    
    let funDate: Date
    let habits: [HabitRecord]
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        let twoDaysAgo = Date().noon!.adding(days: -2)
        let threeDaysAgo = Date().noon!.adding(days: -3)
        let fourDaysAgo = Date().noon!.adding(days: -4)
        switch funDate {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        case twoDaysAgo:
            return "-2 days"
        case threeDaysAgo:
            return "-3 days"
        case fourDaysAgo:
            return "-4 days"
        default:
            return formatter.string(from: funDate)
        }
    }
}


struct BarView: View {
    
    
    let habitRepository: HabitRepository
    let graphHeight: CGFloat
    
    @Binding var habitsOnDates: [HabitsOnDate]

    
    var body: some View {
        
        let columnWidth = graphHeight / 5
        
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(0..<habitsOnDates.count, id: \.self) { i in
                        dateColumn(graphHeight: graphHeight, info: habitsOnDates[i])
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                    }
                }
                .frame(height: graphHeight)
//                    .background(Color.green)
            }
//            .onAppear {
//                print("onAppear habitsOnDates: \(habitsOnDates)")
//                value.scrollTo(habitsOnDates.count - 1)
//            }
            .onChange(of: habitsOnDates) { oldValue, newValue in
                print("changed habitsOnDates")
                if oldValue.isEmpty {
                    value.scrollTo(habitsOnDates.count - 1)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func dateColumn(graphHeight: Double, info: HabitsOnDate) -> some View {
        
        let habitCount = info.habits.count
        let labelHeight: CGFloat = 30
        // This will also be the usual height
        let itemWidth = (graphHeight - labelHeight) / 8
        let itemHeight = habitCount > 8 ? ((graphHeight - labelHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {
            ForEach(info.habits, id: \.self) { j in
                Rectangle()
                    .fill(j.habit.color)
                    .frame(width: itemWidth, height: itemHeight)
            }
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: 1)
            
            Text("\(info.displayDate)")
                .frame(maxWidth: .infinity, maxHeight: labelHeight )
//                .background(Color.red)
        }
    }
}


extension Date {
    var noon: Date? {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}


struct HabitsMenu: View {
    
    // TODO: load habits from db
    @State private var availableHabits = Habit.habits
    
    let habitRepository: HabitRepository
    let habitMenuHeight: CGFloat
    let didTapHabitButton: (Habit) -> Void
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                Text("Habits")
                    .font(.title2)
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.title2)
            }
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.vertical, 30)
            
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(0..<availableHabits.count, id: \.self) { i in
                        
                        let habit = availableHabits[i]
                        habitButton(habit: habit)
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
//            .frame(height: habitMenuHeight)
//            .background(Color.indigo)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20))
        .padding()
    }
    
    
    func habitButton(habit: Habit) -> some View {
        
        Button {
            didTapHabitButton(habit)
        } label: {
            Text("\(habit.name)")
                .fontWeight(.semibold)
                .font(.system(size: 17))
                .frame(width: 150, height: 50)
                .background(habit.color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}


struct HomeView: View {
    
    let habitRepository: HabitRepository
    
    @State private var habitsOnDates = [HabitsOnDate]()
    
    /*
     * I want to be able to have some way that I can monitor any changes to the database and when
     * I detect a change, I will run the little refresh function and place everything in the right
     * spot. So instead of adding to anything in-memory. I would save directly to the db and let
     * it work through by itself
     *
     * Until I hook that up, I can hold everything here. Load it on the onAppear. Then I can
     * add the new habit record to the in-memory variable holding all of our record data. When
     * I do this, I will essentially "pretend" that we are monitoring changes, and manually call
     * the refresh method (which uses this in-memory variable) and have the graph hopefully refresh
     *
     */

    var body: some View {
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let safeAreaInsetTop = proxy.safeAreaInsets.top
            let graphHeight = screenHeight * 0.5
            let habitMenuHeight = screenHeight * 0.3
            let itemHeight = graphHeight / 8
            
            let _ = print("safeAreaInsetTop: \(safeAreaInsetTop)")
            let _ = print("graphHeight: \(graphHeight)")
            let _ = print("screenHeight: \(screenHeight)")
            let _ = print("itemHeight: \(itemHeight)")
            
            VStack {
                BarView(habitRepository: habitRepository, graphHeight: graphHeight, habitsOnDates: $habitsOnDates)
                HabitsMenu(habitRepository: habitRepository, habitMenuHeight: habitMenuHeight, didTapHabitButton: createHabitRecordOnDate)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .onAppear {
                updateHabitsOnDates()
            }
        }
    }
    
    
    private func updateHabitsOnDates() {
        
        habitsOnDates = []
        
        print("update habit records by loading them")
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        calendar.locale = .current
        
        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon,
              let today = Date().noon,
              let days = calendar.dateComponents([.day], from: startOf2024, to: today).day
        else { return }
        
        
        // TODO: Get ALL habit records (make sure they are sorted by date in ascending order oldest -> latest)
        DispatchQueue.main.async {
            habitRepository.fetchAllHabitRecords { habitRecords in
                
                print("received from habitRepository fetch... \(habitRecords.count)")
                let habitRecords = habitRecords.sorted {
                    $0.completionDate > $1.completionDate
                }
                
                // Convert to a dictionary in order for us to an easier time in searching for dates
                var dict = [Date: [HabitRecord]]()
                
                for record in habitRecords {
                    
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
                        habitsOnDates.append(HabitsOnDate(funDate: noonDate, habits: habitRecordsForDate))
                    } else {
                        habitsOnDates.append(HabitsOnDate(funDate: noonDate, habits: []))
                    }
                }
                
                print("POST OPERATION: \(habitsOnDates)")
            }
        }
    }
    
    private func createHabitRecordOnDate(habit: Habit) {
        
        print("create habit record on selected date (for \(habit.name))")
        
        let today = Date()
        let todayNoon = today.noon!
        let selectedDay = AppState.shared.selectedDate
        let selectedDateNoon = selectedDay.noon!
        
        var newHabitRecordCompletionDate: Date!
        

        if todayNoon == selectedDateNoon {
            // we do this because we want the exact time, for ordering purposes, on the given day
            newHabitRecordCompletionDate = today
        } else {
            // If the day has already passed (which is the only other option)
            // then we do not care the exact completionDate, and we will not be giving
            // we'll just get the latest most that we can come up with and make
            // the creationDate accurate for any sorting ties later additions would
            // make
            
            // Sets to the
            var selectedDayDateComponents = Calendar.current.dateComponents(in: .current, from: selectedDay)
            selectedDayDateComponents.hour = 23
            selectedDayDateComponents.minute = 59
            selectedDayDateComponents.second = 59
            
            newHabitRecordCompletionDate = selectedDayDateComponents.date!
        }
        
        let newHabitRecord = HabitRecord(creationDate: today, completionDate: newHabitRecordCompletionDate, habit: habit)
        
        habitRepository.insertNewHabitRecord(newHabitRecord) { error in
            if let error {
                fatalError("There was an issue \(error.localizedDescription)")
            }
            
            print("finished inserting without an error")
            updateHabitsOnDates()
        }
    }
}


struct ContentView: View {
    
    let habitRepository: HabitRepository
    
    var body: some View {

        HomeView(habitRepository: habitRepository)
    }
}


class AppState {
    
    static let shared = AppState()
    
    private init() {}
    
    private(set) var selectedDate = Date().noon!
    
    func setSelectedDateToNext() {
        
        print("Go forward in time unless its today")
    }
    
    func setSelectedDateToPrevious() {
        
        print("Go back in time")
    }
}

#Preview {
    ContentView(habitRepository: InMemoryHabitRepository())
}
