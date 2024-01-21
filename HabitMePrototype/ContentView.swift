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
    
    private var habitRecords = HabitRecord.habitRecords // We'll init it with some demo data
    
    
    func fetchAllHabitRecords(completion: (FetchAllHabitRecordsResult) -> Void) {
        
        completion(habitRecords)
    }
    
    
    func insertNewHabitRecord(_ habitRecord: HabitRecord, completion: (InsertNewHabitRecordResult) -> Void) {
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
    let completionDate: Date
    let habit: Habit
    
    static let habitRecords = [
        // Meditation logs
        // 16
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 9).date!,
            habit: Habit.journal
        ),
        // 17
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 17).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 18).date!,
            habit: Habit.meditation
        ),
        // 18
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 14).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 15).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 16).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 17).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 23).date!,
            habit: Habit.journal
        ),
        // 19
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            habit: Habit.meditation
        ),
        // 20
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
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
            .onChange(of: habitsOnDates.count) { oldValue, newValue in
                value.scrollTo(habitsOnDates.count - 1)
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
            createHabitRecordOnDate(habit: habit, date: Date().noon!)
        } label: {
            Text("\(habit.name)")
                .fontWeight(.bold)
                .font(.system(size: 17))
                .frame(width: 150, height: 50)
                .background(habit.color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
    
    
    // logic
    
    private func createHabitRecordOnDate(habit: Habit, date: Date) {
        print("Add \(habit.name) record to \(date)")
        
        let newHabitRecord = HabitRecord(completionDate: Date(), habit: habit)
        
        habitRepository.insertNewHabitRecord(newHabitRecord) { error in
            if let error {
                fatalError("There was an issue \(error.localizedDescription)")
            }
        }
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
                HabitsMenu(habitRepository: habitRepository, habitMenuHeight: habitMenuHeight)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .onAppear {
                updateHabitsOnDates()
            }
        }
    }
    
    
    func updateHabitsOnDates() {
        
        guard let startOf2024 = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date?.noon,
              let today = Date().noon,
              let days = Calendar.current.dateComponents([.day], from: startOf2024, to: today).day
        else { return }
        
        
        // TODO: Get ALL habit records (make sure they are sorted by date in ascending order oldest -> latest)
        habitRepository.fetchAllHabitRecords { habitRecords in
            
            let habitRecords = HabitRecord.habitRecords.sorted {
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
                guard let noonDate = Calendar.current.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return }
                
                
                if let habitRecordsForDate = dict[noonDate] {
                    habitsOnDates.append(HabitsOnDate(funDate: noonDate, habits: habitRecordsForDate))
                } else {
                    habitsOnDates.append(HabitsOnDate(funDate: noonDate, habits: []))
                }
            }
        }
    }
}


struct ContentView: View {
    
    let habitRepository: HabitRepository
    
    var body: some View {

        HomeView(habitRepository: habitRepository)
    }
}

#Preview {
    ContentView(habitRepository: InMemoryHabitRepository())
}
