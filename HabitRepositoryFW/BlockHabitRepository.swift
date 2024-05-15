//
//  BlockHabitRepository.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation


/// Used as a boundary to allow us to replace our CoreDataHabitStore with some other mechanism for saving/retrieving data
public protocol HabitStore {
    
    func createHabit(_ habit: Habit) async throws
//    func readAllNonarchivedHabits() async throws -> [Habit]
//    func readAllArchivedHabits() async throws -> [Habit]
    func readAllHabits() async throws -> [Habit]
    func updateHabit(id: String, with habit: Habit) async throws
    func destroyHabit(_ habit: Habit) async throws
}


public protocol HabitRecordStore {
    
    func createHabitRecord(_ habitRecord: HabitRecord) async throws
    func readAllHabitRecords() async throws -> [HabitRecord]
    func updateHabitRecord(id: String, with habitRecord: HabitRecord) async throws
    func destroyHabitRecord(_ habitRecord: HabitRecord) async throws
}


public protocol BlockHabitRepository: HabitStore, HabitRecordStore { }
