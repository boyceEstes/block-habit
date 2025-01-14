//
//  SelectableHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI
import HabitRepositoryFW

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
    
    VStack {
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

        
        SelectableHabitView(
            habit: IsCompletedHabit(
                habit: .mirrorPepTalk,
                isCompleted: true
            ),
            completeHabit: { _ in },
            goToHabitDetail: { _ in }
        )
    }
    .padding(.horizontal, 8)
}
