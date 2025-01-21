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

//struct FinalSelectableCell: View {
//    
//    /// SF Symbol name
//    let systemName: String
//    let onSelection: () -> Void
//    let viewRefreshedIsCompleted: Bool
//    
//    let color: Color
//    @State var isCompleted = false {
//        didSet {
//            print("boyce - toggling isCompleted state of button to \(isCompleted)")
//        }
//    }
//    @State var scale = 1.0
//    
//    init(color: Color, systemName: String, isCompleted: Bool = false, onSelection: @escaping () -> Void) {
//        
//        self.color = color
//        self.systemName = systemName
//        self.onSelection = onSelection
//        self.viewRefreshedIsCompleted = isCompleted
//        self._isCompleted = State(initialValue: isCompleted)
//        print("boyce - onInit setting it to \(isCompleted ? "completed" : "incomplete")")
//    }
//    
//    
//    var body: some View {
//        
//        image()
//            .scaleEffect(scale)
//            .sensoryFeedback(.increase, trigger: isCompleted)
//            .onTapGesture {
//                isCompleted.toggle()
//                // This will not have the scaling effect - but it will have the color/icon change
//                onSelection()
//                
////                withAnimation {
////                    isCompleted.toggle()
////                }
////                withAnimation(.spring(duration: 0.2)) {
////                    
////                    scale = 1.2
////                    
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
////                        withAnimation() {
////                            scale = 1
////                            onSelection()
////                        }
////                    }
////                }
//            }
//            .onAppear {
//                print("boyce - onAppear setting it to \(isCompleted ? "completed" : "incomplete")")
//                
//            }
//    }
//    
//    
//     @ViewBuilder
//     func image() -> some View {
//         
//         let _ = print("boyce - creating the image to be that of \(isCompleted ? "completed" : "incomplete")")
//         Image(systemName: systemName)
//             .resizable()
//             .aspectRatio(contentMode: .fit)
//             .frame(width: 20, height: 20)
//             .foregroundStyle(.white)
//             .fontWeight(isCompleted ? .semibold : .medium)
//             .scaleEffect(isCompleted ? 1.2 : 0.8)
//             .padding(10)
//             .background(color
//                 .brightness(isCompleted ? 0 : -0.3)
//             )
//             .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//     }
//}



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
        
        let habitGoal = isCompletedHabit.habit.goalCompletionsPerDay ?? 1
        // If this was more than 1 and it was incomplete, go to partially complete
        
        switch isCompletedHabit.status {
        case .incomplete:
            if habitGoal > 1 {
                return .partiallyComplete(count: 1, goal: habitGoal)
            } else if habitGoal == 1 {
                return .complete
            } else {
                // habitGoal is 0, leave on incomplete forever
                return .incomplete
            }
            
        case let .partiallyComplete(count, goal):
            if count + 1 >= goal {
                return .complete
            } else {
                return .partiallyComplete(count: count + 1, goal: goal)
            }
            
        case .complete:
            // Even if there are multiple, if we are tapping a competed habit, it should loop back around.
            return .incomplete
        }
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
                
                withAnimation {
                    animationTrigger = true
                }
                
                withAnimation(.spring(duration: 0.2)) {

                    scale = 1.2

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        withAnimation() {
                            
                            scale = 1
                            // We wait until after animation has complete to trigger this because it will be moved to the "completed section then"
                            isCompletedHabit.status = nextState//nextState(isCompletedHabit: isCompletedHabit)
                            animationTrigger = false
                            tapAction()
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
            .foregroundStyle(.white)
            .fontWeight(animationTrigger == true ? (nextState.isCompleted ? .semibold : .medium) : (isCompletedHabit.isCompleted ? .semibold : .medium))
            .scaleEffect(animationTrigger == true ? (nextState.isCompleted ? 1.2 : 0.8) : (isCompletedHabit.isCompleted ? 1.2 : 0.8))
            .padding(10)
            .background((Color(hex: isCompletedHabit.habit.color) ?? .pink)
                .brightness(animationTrigger == true ? (nextState.isCompleted ? 0 : -0.3) : (isCompletedHabit.isCompleted ? 0 : -0.3))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    
    private func nextState(isCompletedHabit: IsCompletedHabit) -> HabitState {
        
        let habitGoal = isCompletedHabit.habit.goalCompletionsPerDay ?? 1
        // If this was more than 1 and it was incomplete, go to partially complete
        
        switch isCompletedHabit.status {
        case .incomplete:
            if habitGoal > 1 {
                return .partiallyComplete(count: 1, goal: habitGoal)
            } else if habitGoal == 1 {
                return .complete
            } else {
                // habitGoal is 0, leave on incomplete forever
                return .incomplete
            }
            
        case let .partiallyComplete(count, goal):
            if count + 1 >= goal {
                return .complete
            } else {
                return .partiallyComplete(count: count + 1, goal: goal)
            }
            
        case .complete:
            // Even if there are multiple, if we are tapping a competed habit, it should loop back around.
            return .incomplete
        }
    }
}
// Demo
//struct SelectableCell: View {
//    
//    /// SF Symbol name
//    let onSelection: () -> Void
//    let color: Color
////    @State var isCompleted = false {
////        didSet {
////            print("boyce - toggling isCompleted state of button to \(isCompleted)")
////        }
////    }
//    
//    @StateObject var viewModel: SelectableCellViewModel
//    
//    @State var scale = 1.0
//    
//    init(color: Color, systemName: String, isCompleted: Bool = false, onSelection: @escaping () -> Void) {
//        
//        self.color = color
//        self.onSelection = onSelection
////        self._isCompleted = State(initialValue: isCompleted)
//        self._viewModel = StateObject(wrappedValue: SelectableCellViewModel(isCompleted: isCompleted))
////        print("boyce - onInit setting it to \(self.isCompleted ? "completed" : "incomplete")")
//    }
//    
//    
//    var body: some View {
//        
//        image()
//            .scaleEffect(scale)
//            .sensoryFeedback(.increase, trigger: viewModel.isCompleted)
//            .onTapGesture {
//                print("boyce - before toggle, \(viewModel.isCompleted ? "completed" : "incomplete")")
//                viewModel.isCompleted.toggle()
//                print("boyce - after toggle, \(viewModel.isCompleted ? "completed" : "incomplete")")
//                // This will not have the scaling effect - but it will have the color/icon change
//                onSelection()
//            }
//            .onAppear {
//                print("boyce - onAppear setting it to \(viewModel.isCompleted ? "completed" : "incomplete")")
//            }
//    }
//    
//    
//     @ViewBuilder
//     func image() -> some View {
//         
//         let _ = print("boyce - creating the image to be that of \(viewModel.isCompleted ? "completed" : "incomplete")")
//         Image(systemName: "checkmark")
//             .resizable()
//             .aspectRatio(contentMode: .fit)
//             .frame(width: 20, height: 20)
//             .foregroundStyle(.white)
//             .fontWeight(viewModel.isCompleted ? .semibold : .medium)
//             .scaleEffect(viewModel.isCompleted ? 1.2 : 0.8)
//             .padding(10)
//             .background(color
//                .brightness(viewModel.isCompleted ? 0 : -0.3)
//             )
//             .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//     }
//}


//#Preview {
//    
//    SelectableCell(color: .pink, systemName: "checkmark", onSelection: { })
//}
