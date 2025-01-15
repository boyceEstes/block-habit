//
//  SelectableHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI
import HabitRepositoryFW

struct SelectableHabitView2: View {
    
    // MARK: Injected Properties
    let habit: IsCompletedHabit
    let completeHabit: (Habit) -> Void
    let uncompleteHabit: (Habit) -> Void
    
    let goToHabitDetail: (Habit) -> Void
    
    // MARK: View Info
    @ScaledMetric(relativeTo: .body) var detailHeight = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(habit.habit.name)")
                    .hAlign(.leading)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: true)
                    .foregroundStyle(.primary)
                
                
                Spacer()
                
                
                if habit.isCompleted {
                    // Double tap to allow to break through and log again
                    checkmark(isCompleted: habit.isCompleted, color: Color(hex: habit.habit.color) ?? .blue)
                        .gesture(
                            TapGesture(count: 2).onEnded {
                                print("Double tap")
                                uncompleteHabit(habit.habit)
                            }.exclusively(before: TapGesture(count: 1).onEnded {
                                completeHabit(habit.habit)
                            })
                        )
                } else {
                    // Single responsive tap
                    checkmark(
                        isCompleted: habit.isCompleted,
                        color: Color(hex: habit.habit.color) ?? .blue
                    )
                    .onTapGesture {
                        completeHabit(habit.habit)
                    }
                }
            }
            .padding(8)
            .background(Color.secondaryBackground)
            // injecting height to resize the icons according to the height
            ActivityDetailIndicators(
                activityDetails: habit.habit.activityDetails.bjSort(),
                detailHeight: detailHeight
            )
            .fontWeight(.medium)
            .frame(minHeight: detailHeight, maxHeight: detailHeight)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                .fill(
//                    .shadow(.inner(color: habit.isCompleted ? .black.opacity(0.1) : .clear, radius: 3, x: 3, y: 8))
//                )
                .foregroundStyle(Color(hex:habit.habit.color) ?? Color.blue)
//                .brightness(habit.isCompleted ? -0.1 : 0.0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//        .shadow(color: .black.opacity(0.2), radius: 2)
//        .shadow(radius: 5)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
//
//                .stroke(Color(.tertiaryBackground), lineWidth: 1)
//        )

        .contentShape(Rectangle())
        .onTapGesture {
            goToHabitDetail(habit.habit)
        }
    }
    
    @ViewBuilder
    func checkmark(isCompleted: Bool, color: Color) -> some View {
        
        Image(systemName: "checkmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(10)
            .background(color
                        
//                .overlay(isCompleted ? .clear : .black.opacity(0.3))
                .brightness(isCompleted ? 0 : -0.3)
                        
            )
//            .background(isCompleted ? color : .black.opacity(0.4))
//            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 3)
//            .overlay(isCompleted ? .clear : Color.black.opacity(0.4), alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: 10, style: .continuous)
//                    .stroke(isCompleted ? color : color, lineWidth: 2)
//                )
    }
}

struct SelectableHabitView: View {
    
    // MARK: Injected Properties
    let habit: IsCompletedHabit
    let completeHabit: (Habit) -> Void
    let goToHabitDetail: (Habit) -> Void
    
    // MARK: View Info
    @ScaledMetric(relativeTo: .body) var detailHeight = 12
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                    Text("\(habit.habit.name)")
                    .hAlign(.leading)

                    .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(2, reservesSpace: true)
                
                    // injecting height to resize the icons according to the height
                    ActivityDetailIndicators(
                        activityDetails: habit.habit.activityDetails.bjSort(),
                        detailHeight: detailHeight
                    )
                    .frame(minHeight: detailHeight, maxHeight: detailHeight)
                }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                completeHabit(habit.habit)
            } label: {
                // This depends on a lot.
                Image(systemName: "checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(habit.isCompleted ? Color(hex: habit.habit.color) : Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 3)
            }
            .padding(.leading)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    .shadow(.inner(color: habit.isCompleted ? .black.opacity(0.1) : .clear, radius: 3, x: 3, y: 8))
                )
                .foregroundStyle(Color(hex:habit.habit.color) ?? Color.blue)
                .brightness(habit.isCompleted ? -0.1 : 0.0)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            goToHabitDetail(habit.habit)
        }
    }
}

#Preview {
    ZStack {
        Color.primaryBackground
    VStack(spacing: 40) {
        
        
        VStack {
            
            Text("Original")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 8) {
                SelectableHabitView(
                    habit: IsCompletedHabit(
                        habit: .mirrorPepTalk,
                        isCompleted: false
                    ),
                    completeHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
                
                SelectableHabitView(
                    habit: IsCompletedHabit(
                        habit: .drinkTheKoolaid,
                        isCompleted: false
                    ),
                    completeHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
            }
            
            Text("Completed")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                SelectableHabitView(
                    habit: IsCompletedHabit(
                        habit: .mirrorPepTalk,
                        isCompleted: true
                    ),
                    completeHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
                
                SelectableHabitView(
                    habit: IsCompletedHabit(
                        habit: .drinkTheKoolaid,
                        isCompleted: true
                    ),
                    completeHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
            }
        }
        
        
        VStack {
            
            Text("Version 2")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 8) {
                SelectableHabitView2(
                    habit: IsCompletedHabit(
                        habit: .mirrorPepTalk,
                        isCompleted: false
                    ),
                    completeHabit: { _ in },
                    uncompleteHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
                
                SelectableHabitView2(
                    habit: IsCompletedHabit(
                        habit: .drinkTheKoolaid,
                        isCompleted: false
                    ),
                    completeHabit: { _ in },
                    uncompleteHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
            }
            
            Text("Completed")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                SelectableHabitView2(
                    habit: IsCompletedHabit(
                        habit: .mirrorPepTalk,
                        isCompleted: true
                    ),
                    completeHabit: { _ in },
                    uncompleteHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
                
                SelectableHabitView2(
                    habit: IsCompletedHabit(
                        habit: .drinkTheKoolaid,
                        isCompleted: true
                    ),
                    completeHabit: { _ in },
                    uncompleteHabit: { _ in },
                    goToHabitDetail: { _ in }
                )
            }
        }
        
    }
    .padding(.horizontal, 8)
}
}
