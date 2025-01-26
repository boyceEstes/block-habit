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
    @Binding var isCompletedHabits: Set<IsCompletedHabit>
    let completedHabits: [IsCompletedHabit]
    let incompletedHabits: [IsCompletedHabit]
    // Navigation & Actions
    let goToCreateHabit: () -> Void
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    let didTapHabitButton: (IsCompletedHabit) -> Void
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
        Group {
            if !isHabitsEmpty {
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        // MARK: Incompleted Habits
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(0..<incompletedHabits.count, id: \.self) { i in
                                
                                habitButton(
                                    isCompletedHabit: incompletedHabits[i]
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
                                        isCompletedHabit: completedHabits[i]
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
                }
            } else {
                VStack {
                    Spacer()
                    Text("Try adding a habit to start the Block Party! 🎉")
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .multilineTextAlignment(.center)
                        .hAlign(.center)
                        .padding(.top)
                    
                    Button("Get Started") {
                        goToCreateHabit()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .onChange(of: showAlert) { _, newValue in
            // Each time the showAlert is reset, nil out alertDetails
            if !newValue {
                alertDetail = nil
            }
        }
    }
    
    @ViewBuilder
    func habitButton2(habit: IsCompletedHabit) -> some View {
        
    }
    
    @ViewBuilder
    func habitButton(isCompletedHabit: IsCompletedHabit) -> some View {
        
        if let isCompletedHabitBinding = binding(for: isCompletedHabit.habit.id) {
            
            SelectableHabitView2(
                isCompletedHabit: isCompletedHabitBinding,
                tapHabitAction: didTapHabitButton,
                goToHabitDetail: goToHabitDetail
            )
            .contextMenu {
                
                Button("Habit Details") {
                    goToHabitDetail(isCompletedHabit.habit)
                }
                
                Button("Edit Habit") {
                    // FIXME: I need to make sure this updates the isComplete state if we mess with the completion goals
                    goToEditHabit(isCompletedHabit.habit)
                }
                
                Button("Archive Habit", role: .destructive) {
                    archiveHabit(isCompletedHabit.habit)
                }
                
                Button("Delete Habit and All Data", role: .destructive) {
                    
                    print("`make sure your habit is up to date here` they said - \(isCompletedHabit.habit.name)")
                    
                    alertDetail = HabitsMenuAlert.deleteHabit(
                        yesAction: {
                            print("`make sure your habit is up to date here` when tapping yes they said - \(isCompletedHabit.habit.name)")
                            destroyHabit(isCompletedHabit.habit)
                        }
                    ).alertData()
                    
                    showAlert = true
                }
            }
        } else {
            EmptyView()
        }
    }
        
    func binding(for habitID: String) -> Binding<IsCompletedHabit>? {
        guard let isCompletedHabit = isCompletedHabits.first(where: { $0.habit.id == habitID }) else { return nil }
    
        return Binding(
            get: { isCompletedHabit },
            set: { updatedHabit in
                isCompletedHabits.remove(isCompletedHabit) // Remove the old habit
                isCompletedHabits.insert(updatedHabit) // Insert the updated habit
            }
        )
    }
}


#Preview {
    
    HabitsMenu(
        isCompletedHabits:
            Binding(
                get: { []//Set(IsCompletedHabit.previewCompletedHabits)
                }, set:  { _ in }
            ),
        completedHabits: [],//IsCompletedHabit.previewCompletedHabits,
        incompletedHabits: [],//IsCompletedHabit.previewIncompletedHabits,
        goToCreateHabit: { },
        goToHabitDetail: { _ in },
        goToEditHabit: { _ in },
        didTapHabitButton: { _ in },
        archiveHabit: { _ in },
        destroyHabit: { _ in }
    )
}
