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
    @Binding var isCompletedHabit: IsCompletedHabit
    let tapHabitAction: (IsCompletedHabit) -> Void // TODO: I might only need `(Habit) -> Void` prefer simplicity but legacy prefers IsCompletedHabit - defaulting to legacy version for now
    let goToHabitDetail: (Habit) -> Void
    
    // MARK: View Info
    @ScaledMetric(relativeTo: .body) var detailHeight = 14
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(isCompletedHabit.habit.name)")
                    .hAlign(.leading)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: true)
                    .foregroundStyle(.primary)
                
                
                Spacer()
                
                
                SelectableCell2(
                    isCompletedHabit: $isCompletedHabit, // passes the binding and all of the important stuff like color
                    tapAction: {
                        tapHabitAction(isCompletedHabit)
                    }
                )
                
                
//                if isCompletedHabit.isCompleted {
//                    
//                    SelectableCell(
//                        color: Color(hex: isCompletedHabit.habit.color) ?? .yellow,
//                        systemName: "checkmark",
//                        isCompleted: isCompletedHabit.isCompleted,
//                        onSelection: { tapHabitAction(isCompletedHabit) }
//                    )
//                    
//                    // Double tap to allow to break through and log again
//                    checkmark(isCompleted: isCompletedHabit.isCompleted, color: Color(hex: isCompletedHabit.habit.color) ?? .blue)
//                        .gesture(
//                            TapGesture(count: 2).onEnded {
//                                print("Double tap")
////                                uncompleteHabit(habit.habit)
//                            }.exclusively(before: TapGesture(count: 1).onEnded {
//                                tapHabitAction(isCompletedHabit)
//                            })
//                        )
//                } else {
////                    SelectableCell(color: Color(hex: habit.habit.color) ?? .yellow, systemName: "checkmark", onSelection: { completeHabit(habit.habit) })
//                    // Single responsive tap
//                    
//                    SelectableCell(
//                        color: Color(hex: isCompletedHabit.habit.color) ?? .yellow,
//                        systemName: "checkmark",
//                        isCompleted: isCompletedHabit.isCompleted,
//                        onSelection: { tapHabitAction(isCompletedHabit) }
//                    )
//                    
//                    checkmark(
//                        isCompleted: isCompletedHabit.isCompleted,
//                        color: Color(hex: isCompletedHabit.habit.color) ?? .blue
//                    )
//                    .onTapGesture {
//                        tapHabitAction(isCompletedHabit)
//                    }
//                }
            }
            .padding([.top, .horizontal], 8)
//            .background(Color.secondaryBackground)
            // injecting height to resize the icons according to the height
            ActivityDetailIndicators(
                activityDetails: isCompletedHabit.habit.activityDetails.bjSort(),
                detailHeight: detailHeight
            )
            .fontWeight(.medium)
            .frame(minHeight: detailHeight, maxHeight: detailHeight)
            .padding(.bottom, 4)
            .padding(.top, 4)
            .padding(.horizontal, 8)
            .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.secondaryBackground, in:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
        )

        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            goToHabitDetail(isCompletedHabit.habit)
        }
    }
    
    @ViewBuilder
    func checkmark(isCompleted: Bool, color: Color) -> some View {
        
        Image(systemName: "checkmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(10)
            .background(isCompleted ? color : color.lessBright(by: -0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(color, lineWidth: 4)
//            )
//            .background(
//                RoundedRectangle(cornerRadius: 10, style: .continuous)
//                    .stroke(color, lineWidth: 2)
//            )
    }
}

extension Color {
    func lessBright(by amount: Double) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // Reduce brightness
        r = max(r + CGFloat(amount), 0)
        g = max(g + CGFloat(amount), 0)
        b = max(b + CGFloat(amount), 0)
        
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}

//struct SelectableHabitView: View {
//    
//    // MARK: Injected Properties
//    @Binding var isCompletedHabit: IsCompletedHabit
////    let isCompletedHabit: IsCompletedHabit
//    let completeHabit: (Habit) -> Void
//    let goToHabitDetail: (Habit) -> Void
//    
//    // MARK: View Info
//    @ScaledMetric(relativeTo: .body) var detailHeight = 12
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 0) {
//                    Text("\(habit.habit.name)")
//                    .hAlign(.leading)
//
//                    .font(.body)
//                        .fontWeight(.semibold)
//                        .lineLimit(2, reservesSpace: true)
//                
//                    // injecting height to resize the icons according to the height
//                    ActivityDetailIndicators(
//                        activityDetails: habit.habit.activityDetails.bjSort(),
//                        detailHeight: detailHeight
//                    )
//                    .frame(minHeight: detailHeight, maxHeight: detailHeight)
//                }
//            .foregroundStyle(.white)
//            
//            Spacer()
//            
//            Button {
//                completeHabit(habit.habit)
//            } label: {
//                // This depends on a lot.
//                Image(systemName: "checkmark")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 20, height: 20)
//                    .foregroundStyle(.white)
//                    .fontWeight(.semibold)
//                    .padding(10)
//                    .background(isCompletedHabit.isCompleted ? Color(hex: isCompletedHabit.habit.color) : Color.black.opacity(0.5))
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 3)
//            }
//            .padding(.leading)
//        }
//        .padding(8)
//        .frame(maxWidth: .infinity)
//        .background(
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                .fill(
//                    .shadow(.inner(color: isCompletedHabit.isCompleted ? .black.opacity(0.1) : .clear, radius: 3, x: 3, y: 8))
//                )
//                .foregroundStyle(Color(hex:isCompletedHabit.habit.color) ?? Color.blue)
//                .brightness(isCompletedHabit.isCompleted ? -0.1 : 0.0)
//        )
//        .contentShape(Rectangle())
//        .onTapGesture {
//            goToHabitDetail(habit.habit)
//        }
//    }
//}

//#Preview {
//    
//    @State var isCompletedHabit = IsCompletedHabit(habit: .mirrorPepTalk, status: .incomplete)
//    
//    
//    ZStack {
//        Color.primaryBackground
//    VStack(spacing: 40) {
//        
//        
//        VStack {
//            
//            Text("Original")
//                .font(.headline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            HStack(spacing: 8) {
//                SelectableHabitView(
//                    habit: $isCompletedHabit,
//                    completeHabit: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//                
//                SelectableHabitView(
//                    habit: IsCompletedHabit(
//                        habit: .drinkTheKoolaid,
//                        isCompleted: false
//                    ),
//                    completeHabit: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//            }
//            
//            Text("Completed")
//                .frame(maxWidth: .infinity, alignment: .leading)
//            HStack {
//                SelectableHabitView(
//                    habit: IsCompletedHabit(
//                        habit: .mirrorPepTalk,
//                        isCompleted: true
//                    ),
//                    completeHabit: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//                
//                SelectableHabitView(
//                    habit: IsCompletedHabit(
//                        habit: .drinkTheKoolaid,
//                        isCompleted: true
//                    ),
//                    completeHabit: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//            }
//        }
//        
//        
//        VStack {
//            
//            Text("Version 2")
//                .font(.headline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            HStack(spacing: 8) {
//                SelectableHabitView2(
//                    habit: IsCompletedHabit(
//                        habit: .mirrorPepTalk,
//                        isCompleted: false
//                    ),
//                    tapHabitAction: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//                
//                SelectableHabitView2(
//                    habit: IsCompletedHabit(
//                        habit: .drinkTheKoolaid,
//                        isCompleted: false
//                    ),
//                    tapHabitAction: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//            }
//            
//            Text("Completed")
//                .frame(maxWidth: .infinity, alignment: .leading)
//            HStack {
//                SelectableHabitView2(
//                    habit: IsCompletedHabit(
//                        habit: .mirrorPepTalk,
//                        isCompleted: true
//                    ),
//                    tapHabitAction: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//                
//                SelectableHabitView2(
//                    habit: IsCompletedHabit(
//                        habit: .drinkTheKoolaid,
//                        isCompleted: true
//                    ),
//                    tapHabitAction: { _ in },
//                    goToHabitDetail: { _ in }
//                )
//            }
//        }
//        
//    }
//    .padding(.horizontal, 8)
//}
//}
