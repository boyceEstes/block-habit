//
//  HabitsMenu.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import TipKit
import HabitRepositoryFW


struct HabitMenuOptionsTip: Tip {
    
    var title: Text {
        Text("More Options")
    }
    
    var message: Text? {
        
        Text("Long press on habits for more available actions! 👇")
    }
}


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
    
    // MARK: Environment
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    // MARK: Injected Logic
    @Binding var isCompletedHabits: Set<IsCompletedHabit>
    let completedHabits: [IsCompletedHabit]
    let incompletedHabits: [IsCompletedHabit]
    // Navigation & Actions
    let goToCreateHabit: () -> Void
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    let toggleHabitAction: (IsCompletedHabit) -> Void
    let completeHabitAction: (IsCompletedHabit) -> Void
    let archiveHabit: (Habit) -> Void
    let destroyHabit: (Habit) -> Void
    // MARK: View Properties
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    @Namespace private var animationNamespace
    
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
                        if !dynamicTypeSize.isAccessibilitySize {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(0..<incompletedHabits.count, id: \.self) { i in
                                    let uniqueID = "habit_button_\(incompletedHabits[i].habit.name)"
                                    habitButton(
                                        isCompletedHabit: incompletedHabits[i]
                                    )
                                    .matchedGeometryEffect(id: "Habit_Button_\(uniqueID)", in: animationNamespace)
                                }
                            }
                        } else {
                            LazyVStack {
                                ForEach(0..<incompletedHabits.count, id: \.self) { i in
                                    let uniqueID = "habit_button_\(incompletedHabits[i].habit.name)"
                                    habitButton(
                                        isCompletedHabit: incompletedHabits[i]
                                    )
                                    .matchedGeometryEffect(id: "Habit_Button_\(uniqueID)", in: animationNamespace)
                                }
                            }
                        }
                        
                        // MARK: Completed Habits
                        Text("Completed Habits")
                            .font(.headline)
                            .hAlign(.leading)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            .padding(.top)
                        
                        
                        if !completedHabits.isEmpty {
                            
                            TipView(HabitMenuOptionsTip(), arrowEdge: .bottom)
                                .tipBackground(Color.secondaryBackground)

                            if !dynamicTypeSize.isAccessibilitySize {
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(0..<completedHabits.count, id: \.self) { i in
                                        
                                        let uniqueID = "habit_button_\(completedHabits[i].habit.id)"
                                        habitButton(
                                            isCompletedHabit: completedHabits[i]
                                        )
                                        .matchedGeometryEffect(id: "Habit_Button_\(uniqueID)", in: animationNamespace)
                                        .onAppear {
                                            print("completed Habit - \(completedHabits[i].habit.id)")
                                        }
                                    }
                                }
                                .padding(.bottom)
                            } else {
                                LazyVStack {
                                    
                                    ForEach(0..<completedHabits.count, id: \.self) { i in
                                        
                                        let uniqueID = "habit_button_\(completedHabits[i].habit.id)"
                                        habitButton(
                                            isCompletedHabit: completedHabits[i]
                                        )
                                        .matchedGeometryEffect(id: "Habit_Button_\(uniqueID)", in: animationNamespace)
                                        .onAppear {
                                            print("completed Habit - \(completedHabits[i].habit.id)")
                                        }
                                    }
                                }
                            }
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
    func habitButton(isCompletedHabit: IsCompletedHabit) -> some View {
        
        if let isCompletedHabitBinding = binding(for: isCompletedHabit.habit.id) {
            
            SelectableHabitView2(
                isCompletedHabit: isCompletedHabitBinding,
                tapHabitAction: completeHabitAction,
                goToHabitDetail: goToHabitDetail
            )
            .contextMenu {
                
                if isCompletedHabit.isCompleted {
                    Button {
                        // This is meant to toggle the habit to be off
                        toggleHabitAction(isCompletedHabit)
                    } label: {
                        Label("Uncomplete Habit", systemImage: BJAsset.minusCircle.rawValue)
                    }
                    
                    Button {
                        completeHabitAction(isCompletedHabit)
                    } label: {
                        Label("Complete Again", systemImage: BJAsset.checkmark.rawValue)
                    }
                    
                } else {
                    Button {
                        completeHabitAction(isCompletedHabit)
                    } label: {
                        Label("Complete Habit", systemImage: BJAsset.checkmark.rawValue)
                    }
                }
                
                Divider()
                
                Button {
                    goToHabitDetail(isCompletedHabit.habit)
                } label: {
                    Label("Habit Details", systemImage: BJAsset.detail.rawValue)
                }
                
                Button {
                    // FIXME: I need to make sure this updates the isComplete state if we mess with the completion goals
                    goToEditHabit(isCompletedHabit.habit)
                } label: {
                    Label("Edit Habit", systemImage: BJAsset.edit.rawValue)
                }
                
                Button(role: .destructive) {
                    archiveHabit(isCompletedHabit.habit)
                } label: {
                    Label("Archive Habit", systemImage: BJAsset.archive.rawValue)
                }
                
                Button(role: .destructive) {
                    
                    print("`make sure your habit is up to date here` they said - \(isCompletedHabit.habit.name)")
                    
                    alertDetail = HabitsMenuAlert.deleteHabit(
                        yesAction: {
                            print("`make sure your habit is up to date here` when tapping yes they said - \(isCompletedHabit.habit.name)")
                            destroyHabit(isCompletedHabit.habit)
                        }
                    ).alertData()
                    
                    showAlert = true
                } label: {
                    Label("Delete Habit and All Data", systemImage: BJAsset.trash.rawValue)
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
        toggleHabitAction: { _ in },
        completeHabitAction: { _ in },
        archiveHabit: { _ in },
        destroyHabit: { _ in }
    )
}
