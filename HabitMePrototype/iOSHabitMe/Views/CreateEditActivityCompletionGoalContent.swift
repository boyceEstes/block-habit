//
//  CreateEditActivityCompletionGoalContent.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/19/24.
//

import SwiftUI

/*
 * I want to keep the completion goal in memory even if the toggle is switched
 * off. There is probably a better way to do this, but I'm just going to have a
 * separate state that we can enter it in to. This is nice because it will
 * levae all of the logic in this block of view logic rather than needing
 * more business logic
 *
 *
 * When the toggle is changed - if true, set to transient. if false, set to nil.
 * When the stepper is changed - set the transient.
 *
 * I could make a binding so that when the transient is changed it will
 * update the completion goal. But if I update the transient then it won't
 * do anything else
 *
 * transient does not get from the completionGoal, it will only get from itself
 *
 */


struct CreateEditActivityCompletionGoalContent: View {
    
    @State private var isCompletionGoalWanted: Bool
    /// This will only be used to keep track of values, but `completionGoal` is
    /// the important one.
    @State private var transientCompletionGoal: Int
    @Binding var completionGoal: Int?
    
    init(completionGoal: Binding<Int?>) {
        
        let initialCompletionGoal = completionGoal.wrappedValue ?? 1
        
        self._transientCompletionGoal = State(initialValue: initialCompletionGoal)
        self._completionGoal = completionGoal
        self._isCompletionGoalWanted = State(initialValue: completionGoal.wrappedValue != nil)
    }
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            
                HStack {
                    Toggle("Completion Goal", isOn: $isCompletionGoalWanted)
                        .onChange(of: isCompletionGoalWanted) { _, newValue in
                            if newValue {
                                completionGoal = transientCompletionGoal
                            } else {
                                completionGoal = nil
                            }
                        }
                }
                
                
                if isCompletionGoalWanted {
                    
                    HStack {
                        Text("\(transientCompletionGoal) / Day")
                        
                        Spacer()
                        
                        Stepper("Completions Per Day", value: $transientCompletionGoal, in: 1...20)
                            .onChange(of: transientCompletionGoal) { oldValue, newValue in
                                completionGoal = transientCompletionGoal
                            }
                            .labelsHidden()
                    }
                    .padding(.vertical)
                }
        
            Group {
                if let completionGoal {
                    Text("Log this activity '\(completionGoal)' \(completionGoal > 1 ? "times" : "time") per day to complete your goal")
                } else {
                    Text("No completion goal. Log as many as humanly possible.")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .sectionBackground()
        .padding(.horizontal)
    }
}


#Preview {
    
    @Previewable @State var completionGoal: Int? = 1
    
    return CreateEditActivityCompletionGoalContent(completionGoal: $completionGoal)
}
