//
//  HabitsMenu.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


struct ActionDetail: Hashable {
    
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    
    
    init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    
    public static func == (lhs: ActionDetail, rhs: ActionDetail) -> Bool {
        lhs.title == rhs.title
    }
    
    
    static func ok(buttonAction: @escaping (() -> Void) = {}) -> ActionDetail {
        ActionDetail(title: .ok, action: buttonAction)
    }
    
    
    static func cancel(buttonAction: @escaping (() -> Void) = {}) -> ActionDetail {
        ActionDetail(title: .cancel, role: .cancel, action: buttonAction)
    }
}


struct AlertDetail {
    
    let title: String
    let message: String
    let actions: [ActionDetail]
    
    
    init(title: String, message: String, actions: [ActionDetail] = [.ok()]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    
    static func okAlert(title: String, message: String, buttonAction: @escaping () -> Void = { }) -> AlertDetail {
        
        AlertDetail(title: title, message: message, actions: [.ok(buttonAction: buttonAction)])
    }
    
    
    static func destructiveAlert(title: String, message: String, cancelAction: @escaping () -> Void = {}, destroyTitle: String, destroyAction: @escaping () -> Void) -> AlertDetail {
        
        AlertDetail(title: title, message: message, actions: [
            .cancel(buttonAction: cancelAction),
            ActionDetail(title: destroyTitle, role: .destructive, action: destroyAction)
        ])
    }
}


extension View {
    
    @ViewBuilder
    func alert(showAlert: Binding<Bool>, alertDetail: AlertDetail?) -> some View {
        
        if let alertDetail {
            alert(
                alertDetail.title,
                isPresented: showAlert,
                presenting: alertDetail,
                actions: { data in
                    ForEach(alertDetail.actions, id: \.self) { alertAction in
                        Button(alertAction.title, role: alertAction.role, action: alertAction.action)
                    }
                }, message: { data in
                    Text(data.message)
                }
            )
        } else {
            alert("Unknown Issue", isPresented: showAlert, actions: { }, message: {
                Text("Some problem has occurred with displaying an error alert - that's weird.")
            })
        }
    }
}


enum HabitsMenuAlert {
    case deleteHabit(yesAction: () -> Void)
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .deleteHabit(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Are you sure?",
                message: "This will delete all of the habit's associated records as well 👀",
                destroyTitle: "Destroy It All",
                destroyAction: yesAction
            )
        }
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
    
    @Environment(\.modelContext) var modelContext
    
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    
    
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    
    // TODO: load habits from db
    let habits: [IsCompletedHabit]
    
    //    let habitMenuHeight: CGFloat
    let didTapCreateHabitButton: () -> Void
    let didTapHabitButton: (Habit) -> Void
    let archiveHabit: (Habit) -> Void
    let destroyHabit: (Habit) -> Void
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                Text("Habits")
                Spacer()
                Button {
                    didTapCreateHabitButton()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .homeDetailTitle()
            .padding(.horizontal)
            .padding(.vertical)
            
            
            ScrollView {
                if !habits.isEmpty {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(0..<habits.count, id: \.self) { i in
                            
                            habitButton(
                                habit: habits[i]
                            )
//                            HabitButton(
//                                habit: habits[i],
//                                goToHabitDetail: goToHabitDetail,
//                                goToEditHabit: goToEditHabit,
//                                destroyHabit: destroyHabit,
//                                createHabitRecord: didTapHabitButton
//                            )
                        }
                    }
                    .padding(.bottom)
                } else {
                    
                    VStack {
                        Spacer()
                        Text("Try adding a habit to start the Block Party! 🎉")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(width: 200, height: 250)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.secondaryBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 20))
        .padding()
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
    }
    
    func habitButton(habit: IsCompletedHabit) -> some View {
        
        HabitMePrimaryButton(
            title: "\(habit.habit.name)",
            color: Color(hex: habit.habit.color)?.opacity(habit.isCompleted ? 0.5 : 1),
            buttonWidth: 150,
            action: { didTapHabitButton(habit.habit) }
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
//                alertDetail = HabitsMenuAlert.deleteHabit(yesAction: {
                    // FIXME: Cannot get alerts to work - it will not get the new state for the next button press on delete
                    print("DELETE HABIT")
                destroyHabit(habit.habit)
//                }).alertData()
//                showAlert = true
            }
        }
    }
}
