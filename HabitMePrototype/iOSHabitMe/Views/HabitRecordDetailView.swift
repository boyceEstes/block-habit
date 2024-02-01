//
//  HabitRecordDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import SwiftData


enum HabitRecordDetailAlert {
    case areYouSure(yesAction: () -> Void)
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .areYouSure(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Are you sure?",
                message: "This will delete the record. You'll have to tap a whole button to put another one back. Then another few buttons to edit the time to this record's time. Big steaks.",
                destroyTitle: "Exterminate Record",
                destroyAction: yesAction
            )
        }
    }
}

struct HabitRecordDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // We only want to be able to edit their time, always maintain the date.
    let habitRecord: DataHabitRecord
    
    @State private var editableCompletionTime: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            SheetTitleBar(
                title: habitRecord.habit?.name ?? "Could Not Find Habit",
                subtitle: DateFormatter.shortDate.string(from: habitRecord.completionDate)
            ) {
                HStack(spacing: 20) {
                    HabitMeDeleteButton {
                        alertDetail = HabitRecordDetailAlert.areYouSure(yesAction: {
                            removeHabitRecord(habitRecord)
                        }).alertData()
                        showAlert = true
                    }
                    HabitMeSheetDismissButton(dismiss: { dismiss() })
                }
            }
            
            VStack {
                DatePicker("Completion Time", selection: $editableCompletionTime, displayedComponents: .hourAndMinute)
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .onAppear {
            editableCompletionTime = habitRecord.completionDate
        }
        .onChange(of: editableCompletionTime) {
            // Adding this check to prevent from doing update logic when we first tap on the row
            if editableCompletionTime != habitRecord.completionDate {
                let new = DateFormatter.shortDateShortTime.string(from: editableCompletionTime)
                print("changed to \(new)")
                updateHabitRecord(habitRecord, withNewCompletionTime: editableCompletionTime)
            }
        }
    }
    
    
    // MARK: Logic
    private func removeHabitRecord(_ habitRecord: DataHabitRecord) {
        
        DispatchQueue.main.async {
            
            modelContext.delete(habitRecord)
            
            dismiss()
        }
    }
    
    
    private func updateHabitRecord(_ habitRecord: DataHabitRecord, withNewCompletionTime newCompletionTime: Date) {
        
        habitRecord.completionDate = newCompletionTime
    }
}




struct HabitMeDeleteButton: View {
    
    let deleteAction: () -> Void
    
    var body: some View {
        Button {
            
            deleteAction()
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(Color.red)
                .font(.title2)
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugged Dew",
        color: Habit.habits[0].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    
    container.mainContext.insert(dataHabit)
    
    let dataHabitRecord = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord)
    
    
    return HabitRecordDetailView(habitRecord: dataHabitRecord)
}
