//
//  CreateHabitRecordWithDetailsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import SwiftData

struct CreateHabitRecordWithDetailsView: View {
    
    // We pass this in and use its information along with the current
    // datetime to autopopulate some details
    let activity: DataHabit
    @State private var activityRecord: DataHabitRecord
    
    init(activity: DataHabit) {
        
        self.activity = activity
        
        self._activityRecord = State(
            initialValue: DataHabitRecord(
                creationDate: Date(),
                completionDate: Date(),
                habit: nil, // Setting this as nil instead of the habit because I can't trust habit data
                activityDetailRecords: []
            )
        )
        
        var activityRecordDetails = activity.activityDetails.map {
            
            // If the valueType == Text, then we will initialize with nothing.
            // otherwise if the it is a number...we will initialize with nothing.
            
            // When we are setting this up... we want toreference it to the place its coming from?
            // which is the activity detail. This caused an error when we created it like this from
            // habit record
            // So be prepared for a FIXME: THIS MIGHT CRASH IN THE FUTURE
            DataActivityDetailRecord(
                value: "",
                activityDetail: $0,
                activityRecord: self.activityRecord
            )
        }
        
        // Maybe I should wait until after we enter the information to do this part?
        // I'm not sure how this will work, inserting this information into activityRecord now
        // is that a circular reference?
//        self.activityRecord.activityDetailRecords = activityRecordDetails
        
        
        // This should possibly be set later. Lets just try to set the variables now and update them
        // later after we hit the create button to prevent fun weird stuff happening.
    }
    
    var body: some View {
        
        Text("hello world")
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
    
    container.mainContext.insert(dataHabit)
    
    return CreateHabitRecordWithDetailsView(activity: dataHabit)
        .modelContainer(container)
}
