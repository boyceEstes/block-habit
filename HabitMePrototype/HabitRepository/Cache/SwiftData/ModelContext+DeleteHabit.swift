//
//  ModelContext+DeleteHabit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/30/24.
//

import SwiftData



/*
 * This is because there is some problem with deleting habit not cascading
 * and deleting the records properly... I think. The error that I have been getting
 * looks like this:
 *
 
 {
     @storageRestrictions(accesses: _$backingData, initializes: _color)
         init(initialValue) {
                     _$backingData.setValue(forKey: \.color, to: initialValue)
                     _color = _SwiftDataNoType()
         }

     get {
                     _$observationRegistrar.access(self, keyPath: \.color)
HERE >>>                     return self.getValue(forKey: \.color)
         }

     set {
                     _$observationRegistrar.withMutation(of: self, keyPath: \.color) {
                             self.setValue(forKey: \.color, to: newValue)
                     }
         }
 }
 
 *
 * I have tried making the Habit property optional, but that doesn't do aything.
 * I tried messing with the simulator's database, to delete a habit record without deleting
 * any of its records and it gives the same error as I'm seeing naturally happen on my
 * physical device... I can't figure out another way to reproduce it. It usually works
 * fine on the simulator.
 *
 * The repro steps in making this occur the first time:
 * 1. Delete some "Habit"
 * 2. Create some Habit Record.
 * 💥💥 Crash
 * App will no longer open up because the records saved are in a bad spot.
 *
 * TLDR: This will be my solution which will manually delete the records first before deleting
 * a habit
 */

extension ModelContext {
    
    ///
    /// TODO: REMOVE WHEN `.cascade` is fixed
    ///
    
    func delete(habit: DataHabit) {
        
        if !habit.habitRecords.isEmpty {
            for record in habit.habitRecords {
                self.delete(record)
            }
            
            self.delete(habit)
        } else {
            // Did not delete records if this was not in the else-block, first attempt was to
            // To assume it had synchronous behavior and delete after the if! block
            self.delete(habit)
        }
    }
}
