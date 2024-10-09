//
//  HabitsMenu.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import HabitRepositoryFW



extension View {
    
    func homeDetailTitle() -> some View {
        modifier(HomeDetailTitle())
    }
}

struct HomeDetailTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
    }
}




struct HabitsMenu: View {
    
    // MARK: Injected Logic
    let completedHabits: [IsCompletedHabit]
    let incompletedHabits: [IsCompletedHabit]
    // Navigation & Actions
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    let didTapHabitButton: (Habit) -> Void
    let archiveHabit: (Habit) -> Void
    let destroyHabit: (Habit) -> Void
    // MARK: View Properties
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var isHabitsEmpty: Bool {
        completedHabits.isEmpty && incompletedHabits.isEmpty
    }
    
    
    var body: some View {
            
        ScrollView(showsIndicators: false) {
                if !isHabitsEmpty {
                    VStack {
                        // MARK: Incompleted Habits
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(0..<incompletedHabits.count, id: \.self) { i in
                                
                                habitButton(
                                    habit: incompletedHabits[i]
                                )
                            }
                        }
                        
                        // MARK: Completed Habits
                        Text("Completed Habits")
                            .font(.headline)
                            .hAlign(.leading)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            .padding(.top)
                        
                        
                        if !completedHabits.isEmpty {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(0..<completedHabits.count, id: \.self) { i in
                                    
                                    habitButton(
                                        habit: completedHabits[i]
                                    )
                                    .onAppear {
                                        print("completed Habit - \(completedHabits[i].habit.name)")
                                    }
                                }
                            }
                            .padding(.bottom)
                        } else {
                            Text("So... you haven't completed any habits at all, huh? 👀 No judgement")
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .hAlign(.leading)
                                .padding(.top, 4)
                        }
                    }
                } else {
                        Text("Try adding a habit to start the Block Party! 🎉")
                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            .multilineTextAlignment(.center)
                            .hAlign(.center)
                            .padding(.top)
                }
            }
            .padding(.horizontal)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
    }
    
    func habitButton(habit: IsCompletedHabit) -> some View {
        
        SelectableHabitView(
            habit: habit,
            completeHabit: didTapHabitButton,
            goToHabitDetail: goToHabitDetail
        )
        .contextMenu {
            
            Button("Habit Details") {
                goToHabitDetail(habit.habit)
            }
            
            Button("Edit Habit") {
                goToEditHabit(habit.habit)
            }
            
            Button("Archive Habit", role: .destructive) {
                archiveHabit(habit.habit)
            }
            
            
            Button("Delete Habit and All Data", role: .destructive) {
                
                alertDetail = HabitsMenuAlert.deleteHabit(yesAction: {
                    destroyHabit(habit.habit)
                }).alertData()
                showAlert = true
            }
        }
    }
}


#Preview {
    
    HabitsMenu(
        completedHabits: IsCompletedHabit.previewCompletedHabits,
        incompletedHabits: IsCompletedHabit.previewIncompletedHabits,
        goToHabitDetail: { _ in },
        goToEditHabit: { _ in },
        didTapHabitButton: { _ in },
        archiveHabit: { _ in },
        destroyHabit: { _ in }
    )
}
