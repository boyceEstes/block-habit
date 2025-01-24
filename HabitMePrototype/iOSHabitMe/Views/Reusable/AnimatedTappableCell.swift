//
//  AnimatedTappableCell.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/15/25.
//

import SwiftUI
import HabitRepositoryFW

/*
 
 Part of the problem here is that we would need to
 be able to detect pretty immediately when the habit
 `isComplete` - so it would seem like we might need a view
 local state property.
 
 Toggle that, and then actually trigger it in the other stuff
 
 
 Instead of having adding a habit record and then reading the latest and updating the habits iscompleted.
 
 Let's
 1. Toggle the habit's isComplete in a state binding
 2. Add a habit record.
 2a. If the habit record fails. Rollback the isComplete
 2b. We want to have some sort of 
 */

struct SelectableCell2: View {
    
    // MARK: Injected Properties
    @Binding var isCompletedHabit: IsCompletedHabit
    let tapAction: () -> Void
    
    
    // MARK: View Properties
    @State var scale = 1.0
    @State var animationTrigger = false
    
    
    init(isCompletedHabit: Binding<IsCompletedHabit>, tapAction: @escaping () -> Void) {
        
        self._isCompletedHabit = isCompletedHabit
        self.tapAction = tapAction
    }
    
    var nextState: HabitState {
        
        isCompletedHabit.nextState()
    }
    
    // The new problem is that it is changing too fast to the completed section.
    // I want to make sure it waits to actually set the state:
    // 1. set view-internal nextState
    // 2. after completed animation, set the binding nextState
    // 3. tapAction()
    
    var body: some View {
        
        // I can extract tappedToANewStateVariable - update completed at the end of the tap by going to the next state... right?
        image()
            .scaleEffect(scale)
            .sensoryFeedback(.increase, trigger: animationTrigger) // This will happen when we tap, as it will change to something else
            .onTapGesture {
                
                if !animationTrigger {
                    
                    withAnimation {
                        animationTrigger = true
                    }
                    
                    withAnimation(.spring(duration: 0.2)) {
                        
                        scale = 1.2
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            
                            withAnimation() {
                                
                                scale = 1
                                // I could probably update the isCompletedHabitStatus to the next state in the habitController...
                                // Then we could use the same logic when we are doing it from another view without this button... would this work?
                                
                                // We wait until after animation has complete to trigger this because it will be moved to the "completed section then"
                                //nextState(isCompletedHabit: isCompletedHabit)
                                
                                tapAction()
                                animationTrigger = false
                            }
                        }
                    }
                }
                // This will not have the scaling effect - but it will have the color/icon change
//                tapAction()
            }
//            .onAppear {
//                print("boyce - onAppear setting it to \(viewModel.isCompleted ? "completed" : "incomplete")")
//            }
    }
    
    /*
     The problem:
     I want to be able to animate whenever I tap the button, I don't want to change the value of the binding until after the animation
     So how do I tell it what to animate to without changing the state
     
     I can say true when we tap and then set to false.
     If it is true, then we want to check the next state to show colors,
     If it is false, then we want to check the current state to show colors
     */
    
    @ViewBuilder
    func image() -> some View {
        
        Image(systemName: "checkmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(animationTrigger == true ? (nextState.isCompleted ? Color.white : Color(.lightGray)) : (isCompletedHabit.isCompleted ? Color.white : Color(.lightGray)))
            .fontWeight(animationTrigger == true ? (nextState.isCompleted ? .semibold : .medium) : (isCompletedHabit.isCompleted ? .semibold : .medium))
            .scaleEffect(animationTrigger == true ? (nextState.isCompleted ? 1.2 : 0.8) : (isCompletedHabit.isCompleted ? 1.2 : 0.8))
            .padding(10)
            .background(
                animationTrigger == true ? (nextState.isCompleted ? isCompletedHabit.habit.realColor : isCompletedHabit.habit.incompleteColor) : isCompletedHabit.isCompleted ? isCompletedHabit.habit.realColor : isCompletedHabit.habit.incompleteColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//#Preview {
//    
//    SelectableCell(color: .pink, systemName: "checkmark", onSelection: { })
//}
