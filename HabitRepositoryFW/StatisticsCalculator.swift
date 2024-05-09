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
    
    
    // Who knows
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
}
