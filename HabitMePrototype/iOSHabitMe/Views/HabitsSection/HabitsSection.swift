//
//  HabitsSection.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI
import HabitRepositoryFW


@Observable
class HabitSectionViewModel {
    
    // Injected Dependencies
    let habitController: HabitController
    let goToCreateActivityRecordWithDetails: GoToCreateHabitRecordWithDetailsType
    // State Properties
    var showAlert = false
    var alertDetail: AlertDetail?
    
    
    init(
        habitController: HabitController,
        goToCreateActivityRecordWithDetails: @escaping GoToCreateHabitRecordWithDetailsType
    ) {
        
        self.habitController = habitController
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
    }
    
    
    func newToggleHabit(
        override: Bool = false,
        isCompletedHabit: IsCompletedHabit
    ) {
        do {
            try habitController.newToggleHabit(
                override: override,
                isCompletedHabit: isCompletedHabit,
                goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
            )
            
        } catch HabitControllerError.uncompleteHabitWithRecordWithDetails(let isCompleteHabit) {
            displayWarningForUncompleteWithDetails(isCompletedHabit: isCompleteHabit)
            
        } catch HabitControllerError.uncompleteHabitWithMultipleRecords(let isCompleteHabit) {
            displayWarningForUncompleteWithRecords(isCompletedHabit: isCompleteHabit)
            
            
        } catch {
            // FIXME: I need a fix!
            fatalError(error.localizedDescription)
        }
    }
    
    
    private func displayWarningForUncompleteWithRecords(isCompletedHabit: IsCompletedHabit) {
        
        alertDetail = AlertDetail(
            title: .habitSectionMenu_uncompletingMultipleRecordsTitle,
            message: .habitSectionMenu_uncompletingMultipleRecordsMessage,
            actions: [
                ActionDetail(title: .nevermind, role: .cancel, action: { }),
                ActionDetail(title: .uncomplete, role: .destructive, action: { [weak self] in
                    
                    guard let self else { return }
                    
                    newToggleHabit(override: true, isCompletedHabit: isCompletedHabit)
                })
            ]
        )
        showAlert = true
    }
    
    
    private func displayWarningForUncompleteWithDetails(isCompletedHabit: IsCompletedHabit) {
        
        alertDetail = AlertDetail(
            title: .habitSectionMenu_uncompletingRecordsWithDetailsTitle,
            message: .habitSectionMenu_uncompletingRecordsWithDetailsMessage,
            actions: [
                ActionDetail(title: .nevermind, role: .cancel, action: { }),
                ActionDetail(title: .uncomplete, role: .destructive, action: { [weak self] in
                    
                    guard let self else { return }
                    
                    newToggleHabit(override: true, isCompletedHabit: isCompletedHabit)
                })
            ]
        )
        showAlert = true
    }
}





struct HabitsSection: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    // MARK: Environment Logic
    @EnvironmentObject var habitController: HabitController
    
    @Bindable var viewModel: HabitSectionViewModel
    // Navigation
    let goToHabitDetail: (Habit) -> Void
    let goToEditHabit: (Habit) -> Void
    let goToCreateHabit: () -> Void
    // MARK: View Properties
    @ScaledMetric(relativeTo: .title2) var baseTitleWidth: CGFloat = 150
    
    var body: some View {
        
        VStack(spacing: 0) {
            
                HStack {
                    HStack {
                        Button {
                            habitController.goToPrevDay()
                        } label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                        }
                        // FIXME: 2 See more at the definition for that
                        .disabled(habitController.isAllowedToGoToPrevDay() ? false : true)
                        
                        Spacer()
                        
                        Text(habitController.selectedDay.displayDate(dynamicTypeSize))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            habitController.goToNextDay()
                        } label: {
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                        }
                        .disabled(habitController.isAllowedToGoToNextDay() ? false : true)
                    }
                    .frame(maxWidth: scaledSize(for: dynamicTypeSize, base: baseTitleWidth))
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    
                    Spacer()
                    
                    HStack(spacing: 24) {
                        Button {
                            habitController.destroyLastRecordOnSelectedDay()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        .disabled(habitController.isRecordsEmptyForSelectedDay)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        
                        Button(action: goToCreateHabit) {
                            Image(systemName: "plus.circle")
                        }
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    }
                }
                .homeDetailTitle()
            .padding(.horizontal)
            .padding(.vertical)
            
            
            HabitsMenu(
                isCompletedHabits: $habitController.isCompletedHabits,
                completedHabits: habitController.completeHabits,
                incompletedHabits: habitController.incompleteHabits,
                goToCreateHabit: goToCreateHabit,
                goToHabitDetail: goToHabitDetail,
                goToEditHabit: goToEditHabit,
                didTapHabitButton: { habit in
                    // FIXME: 2 - viewModel.createHabitRecord(for: habit)
                    viewModel.newToggleHabit(isCompletedHabit: habit)
                }, archiveHabit: { habit in
                    
                    habitController.archiveHabit(habit)
                }, destroyHabit: { habit in

                    habitController.deleteHabit(habit)
                }
            )
        }
        .alert(showAlert: $viewModel.showAlert, alertDetail: viewModel.alertDetail)
    }
    
    
    // Custom scaling function
    func scaledSize(for dynamicTypeSize: DynamicTypeSize, base: CGFloat) -> CGFloat {
        
        return dynamicTypeSize.isAccessibilitySize ? (base * 0.6) : base
    }
}


#Preview {
    @Previewable @State var viewModel = HabitSectionViewModel(habitController: HabitController(
        blockHabitRepository: CoreDataBlockHabitStore.preview(),
        selectedDay: Date()
    ), goToCreateActivityRecordWithDetails: { _, _, _ in })
    
    
    HabitsSection(
        viewModel: viewModel,
        goToHabitDetail: { _ in },
        goToEditHabit: { _ in },
        goToCreateHabit: { }
    )
    // FIXME: Move away from this environmentObject in favorite of the view model
    .environmentObject(
        HabitController(
            blockHabitRepository: CoreDataBlockHabitStore.preview(),
            selectedDay: Date()
        )
    )
}
