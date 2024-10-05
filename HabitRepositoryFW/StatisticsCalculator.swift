//
//  StatisticsCalculator.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/8/24.
//

import Foundation


public typealias RecordsForDays = [Date: [HabitRecord]]
public typealias HabitWithCount = (habit: Habit, count: Int)

public enum StatisticsCalculator {
    
    // O(N)
    public static func findTotalRecords(for recordsForDays: RecordsForDays) -> Int {
        
        return recordsForDays.values.reduce(0) { $0 + $1.count}
    }
    
    
    // O(1) (?)
    public static func findTotalDays(for recordsForDays: RecordsForDays) -> Int {
        
        return recordsForDays.count
    }
    
    
    public static func findAverageRecordsPerDay(for recordsForDays: RecordsForDays) -> Double {
        
        let totalDays = findTotalDays(for: recordsForDays)
        guard totalDays != 0 else { return -1 }
        let totalRecords = findTotalRecords(for: recordsForDays)
        
        let average = Double(totalRecords) / Double(totalDays)
        return average
    }
    
    
    // Should I have only the given habits in the dictionary? I think so.
    // I would want to call this after I filter the recordsForDays by whatever habits are left, but regardless, I would want to only see these habits
    // Either way, I would need to count up for each habit
    // O(H*D*R) - habits * days
    public static func findHabitWithMostCompletions(for recordsForDays: RecordsForDays, with habits: [Habit]) -> HabitWithCount? {
        
        var mostHabit: Habit?
        var mostHabitCount: Int = 0
        
        // 1. Loop through each habit,
        for habit in habits {
            
            // 2. see how many records each has
            var filteredRecordsForDays = RecordsForDays()
            for (day, records) in recordsForDays {
                
                for record in records {
                    
                    if record.habit == habit {
                        
                        if filteredRecordsForDays[day] == nil {
                            filteredRecordsForDays[day] = [record]
                        } else {
                            filteredRecordsForDays[day]?.append(record)
                        }
                    }
                }
            }
            
            let filteredRecordsCount = findTotalRecords(for: filteredRecordsForDays)
            
            // 3. if recordCount > maxRecordCount set as new one
            if filteredRecordsCount > mostHabitCount {
                mostHabit = habit
                mostHabitCount = filteredRecordsCount
            }
        }
        
        // 4. return the habitCount pair
        return mostHabit == nil ? nil : (mostHabit!, mostHabitCount)
    }
    
    
    public static func findHabitWithBestStreak(for recordsForDays: RecordsForDays, with habits: [Habit]) -> HabitWithCount? {
        
        // We want to have all habits that exist here so that we can easily test their streak values
        var habitStreaks: [Habit: Int] = Dictionary(uniqueKeysWithValues: habits.map {($0, 0)} )
        var habitBestStreaks: [Habit: Int] = Dictionary(uniqueKeysWithValues: habits.map {($0, 0)} )
        
        let numOfDays = recordsForDays.keys.count
        
        // gotta get the startDate of everything
        guard let startDay = recordsForDays.min(by: { $0.key < $1.key })?.key else { return nil }
        
        for i in 0..<numOfDays {
            
            // 1. Get each date's habit records as a set (each habit is unique)
            let day = startDay.adding(days: i)
            let habitRecordsForDay = recordsForDays[day] ?? []
            let habitsInHabitRecordsForDay = Set<Habit>(habitRecordsForDay.map { $0.habit})
            
            // We can leave early if there is nothing here
            guard !habitsInHabitRecordsForDay.isEmpty else { continue }

            // 2. Loop through each available habit
            for habit in habits {
                // 3. If the set contains the habit
                if habitsInHabitRecordsForDay.contains(habit) {
                    // 4. Add 1 to a [habit: int] dictionary
                    // We've already made sure this is initialized as 0
                    habitStreaks[habit]! += 1
                    // If it is the last day
                    if i == numOfDays-1 {
                        // 5. If the set does not contain the habit
                        // 6. check to see if the [habit: int] dictionary value is greater than the best [habit: int] value
                        if habitStreaks[habit]! > habitBestStreaks[habit]! {
                            // 7. set best [habit: int] to the value of the whatever and zero out the og [habit: int]
                            habitBestStreaks[habit] = habitStreaks[habit]
                            habitStreaks[habit] = 0
                        } else {
                            habitStreaks[habit] = 0
                        }
                    }
                } else {
                    // 5. If the set does not contain the habit
                    // 6. check to see if the [habit: int] dictionary value is greater than the best [habit: int] value
                    if habitStreaks[habit]! > habitBestStreaks[habit]! {
                        // 7. set best [habit: int] to the value of the whatever and zero out the og [habit: int]
                        habitBestStreaks[habit] = habitStreaks[habit]
                        habitStreaks[habit] = 0
                    } else {
                        habitStreaks[habit] = 0
                    }
                }
            }
        }
        
        guard let bestStreak = habitBestStreaks.max(by: { $0.value < $1.value }),
              bestStreak.value != 0
        else { return nil }
        

        return (bestStreak.key, bestStreak.value)
    }
    
    
    public static func findCurrentUsageStreak(
        for recordsForDays: RecordsForDays
    ) -> Int {
        
        guard !recordsForDays.isEmpty else { return 0 }
        guard let highestDate = recordsForDays.keys.max() else {
            return 0
        }
        
        var currentDay = highestDate
        var streakCount = 0
        
        if let selectedDayRecords = recordsForDays[currentDay],
           selectedDayRecords.isEmpty {
            
            // Start with the previousDay
        } else {
            // We start with now!
            streakCount += 1
        }
        
        currentDay = currentDay.adding(days: -1)
        
        // Keep going until currentDay is nil or current Day has no records
        while recordsForDays[currentDay] != nil && !(recordsForDays[currentDay] ?? []).isEmpty {
            
            streakCount += 1
            currentDay = currentDay.adding(days: -1)
        }
        
        
        return streakCount
    }
}


// MARK: Statistics for records of only one Habit
extension StatisticsCalculator {
    
    struct ImportantDayIntervalInfo {
        
        let startDay: Date
        let lastDay: Date
        let numOfDays: Int
    }
    
    private static func calculateImportantDayIntervalInfo(
        for recordsForDays: RecordsForDays
    ) throws -> ImportantDayIntervalInfo {
        
        guard let startDay = recordsForDays.min(by: { $0.key < $1.key })?.key,
              let lastDay = recordsForDays.max(by: {$0.key < $1.key})?.key
        else { throw NSError(domain: "Cannot calculate start and end day", code: 1) }
        
        // We have to do it this way because there COULD (shouldn't be but it has happened) gaps between the inserted dates in the recordsForDays
        guard let daysBetweenEdges = Calendar.current.dateComponents([.day], from: startDay, to: lastDay).day
        else { throw NSError(domain: "Cannot calculate interval between start and end day", code: 1) }
        
        // add one to include edge day (instead of just the difference in days)
        let numOfDays = daysBetweenEdges + 1
        
        return ImportantDayIntervalInfo(startDay: startDay, lastDay: lastDay, numOfDays: numOfDays)
    }
    
    
    /// If there is no date found there is no current streak
    public static func findCurrentStreakInRecordsForHabit(for recordsForDays: RecordsForDays) -> Int {
        
        var streakCount = 0

        guard let dayIntervalInfo = try? calculateImportantDayIntervalInfo(for: recordsForDays) else { return 0 }
        
        let startDay = dayIntervalInfo.startDay
        let lastDay = dayIntervalInfo.lastDay
        let numOfDays = dayIntervalInfo.numOfDays

        
        print("BOYCE: startDay - \(startDay)")
        print("BOYCE: lastDay - \(lastDay)")
        print("BOYCE: recordsForLastDay - \(recordsForDays[lastDay]?.count ?? -1)")
        
        for i in 0..<numOfDays {
            
            let currentDay = startDay.adding(days: i).noon!
            
            let recordsForCurrentDay = recordsForDays[currentDay]
            // if nil, then it means that theres nothing in it (that shouldn't happen though)
            if !(recordsForCurrentDay?.isEmpty ?? true) {
                
                if currentDay == lastDay {
                    streakCount += 1
                    print("BOYCE: last day - increase count to \(streakCount)")
                } else {
                    streakCount += 1
                    print("BOYCE: record in \(currentDay) increase count")
                }
            } else {
                
                guard currentDay != lastDay else {
                    // This should be the last day, which we don't want to count if it has
                    // not been done yet
                    print("BOYCE: last day - let be and end on \(streakCount)")
                    continue
                }
                
                print("BOYCE: zero out count")
                streakCount = 0
            }
        }
        
        return streakCount
    }
    
    
    /// If there is no date found there is no current streak
    public static func findBestStreakInRecordsForHabit(for recordsForDays: RecordsForDays) -> Int {
        
        var maxStreak = 0
        var streakCount = 0
        
        guard let dayIntervalInfo = try? calculateImportantDayIntervalInfo(for: recordsForDays) else { return 0 }
        
        let startDay = dayIntervalInfo.startDay
        let lastDay = dayIntervalInfo.lastDay
        let numOfDays = dayIntervalInfo.numOfDays
        
        
        for i in 0..<numOfDays {
            
            let currentDay = startDay.adding(days: i)
            
            let recordsForCurrentDay = recordsForDays[currentDay]
            // if nil, then it means that theres nothing in it (that shouldn't happen though)
            if !(recordsForCurrentDay?.isEmpty ?? true) {
                
                streakCount += 1
                
                if streakCount > maxStreak {
                    maxStreak = streakCount
                }
                
            } else {
                
                guard currentDay != lastDay else {
                    // This should be the last day, which we don't want to count if it has
                    // not been done yet
                    continue
                }
                
                streakCount = 0
            }
        }
        
        return maxStreak
    }
}
