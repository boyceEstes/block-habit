//
//  HomeView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


enum HabitRecordVisualMode {
    case bar
    case daily
}

struct HomeView: View {
    
    let habitRepository: HabitRepository
    
    @State private var habitsOnDates = [HabitsOnDate]()
    @State private var habits = [Habit]()
    @State private var isCreateHabitScreenDisplayed = false
    @State private var habitRecordVisualMode: HabitRecordVisualMode = .bar
    @State private var selectedDay: Date = Date().noon!
    
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
                BarView(habitRepository: habitRepository, graphHeight: graphHeight, habitsOnDates: $habitsOnDates, selectedDay: $selectedDay)
                HabitsMenu(
                    habits: $habits,
                    habitMenuHeight: habitMenuHeight,
                    didTapCreateHabitButton: {
                        print("hello world")
                        isCreateHabitScreenDisplayed = true
                    },
                    didTapHabitButton: createHabitRecordOnDate
                )
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .onAppear {
                updateHabitsOnDates()
                getHabits()
            }
        }
        .sheet(isPresented: $isCreateHabitScreenDisplayed, onDismiss: {
            
            updateHabitsOnDates() // Updating this purely so that I can trigger it to get reset to today
            getHabits()
            
        }, content: {
            
            CreateHabitView(habitRepository: habitRepository)
        })
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
            ToolbarItem(placement: .topBarTrailing) {
                
                // TODO: Some logic to dictate whether it is a bar button or a daily log button
                switch habitRecordVisualMode {
                case .bar:
                    // Daily button
                    Button {
                        habitRecordVisualMode = .daily
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .fontWeight(.semibold)
                    }
                case .daily:
                    // Chart button
                    Button {
                        habitRecordVisualMode = .bar
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    
    private var displaySelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
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

    
    private func getHabits() {
        
        habitRepository.fetchAllHabits { habits in
            self.habits = habits
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
        }
    }
    
    private func createHabitRecordOnDate(habit: Habit) {
        
        print("create habit record on selected date (for \(habit.name))")
        
        let today = Date()
        let todayNoon = today.noon!
        let selectedDay = selectedDay
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
