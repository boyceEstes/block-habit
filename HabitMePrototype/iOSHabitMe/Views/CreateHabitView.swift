//
//  CreateHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import HabitRepositoryFW



extension View {
    
    func createEditHabitSheetPresentation() -> some View {
        modifier(CreateEditHabitSheetPresentation())
    }
}


struct CreateEditHabitSheetPresentation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.background)
    }
}


struct DetailUnit: Hashable {
    
    let name: String
    let abbreviatedName: String
    
    static let none = DetailUnit(
        name: "None",
        abbreviatedName: ""
    )
    
    
    static let minutes = DetailUnit(
        name: "Minutes",
        abbreviatedName: "min"
    )
    
    
    static let preloadedOptions = [
        none,
        minutes,
        DetailUnit(
            name: "Miles",
            abbreviatedName: "mi"
        ),
        DetailUnit(
            name: "Kilometers",
            abbreviatedName: "km"
        ),
        DetailUnit(
            name: "Pounds",
            abbreviatedName: "lbs"
        ),
        DetailUnit(
            name: "Kilograms",
            abbreviatedName: "kg"
        ),
        DetailUnit(
            name: "Grams",
            abbreviatedName: "g"
        ),
        DetailUnit(
            name: "Milliliters",
            abbreviatedName: "ml"
        ),
        DetailUnit(
            name: "Liters",
            abbreviatedName: "L"
        ),
        DetailUnit(
            name: "Ounces",
            abbreviatedName: "oz"
        ),
        DetailUnit(
            name: "Fluid Ounces",
            abbreviatedName: "fl oz"
        )
    ]
}


struct HabitDetail: Hashable, Identifiable {
    
    let id = UUID().uuidString
    var name: String
    var valueType: ActivityDetailType
    var unit: DetailUnit // lb, meters, etc. for number
    
    
    static let preloadedHabitDetails = [
        HabitDetail(
            name: "Duration",
            valueType: .number,
            unit: .minutes
        )
    ]
}


struct CreateHabitView: View {
    
    @EnvironmentObject var habitController: HabitController
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // MARK: Injected Properties
    let blockHabitStore: CoreDataBlockHabitStore
    // Navigation
    let goToAddDetailsSelection: (Binding<[ActivityDetail]>, Color?) -> Void
    let goToScheduleSelection: (Binding<ScheduleTimeUnit>, Binding<Int>, Binding<Set<ScheduleDay>>, Binding<Date?>) -> Void
    
    // MARK: View Properties
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    @State private var selectedDetails = [ActivityDetail]()
    @State private var completionGoal: Int? = 1
    // Scheduling
    @State private var schedulingUnits: ScheduleTimeUnit = .weekly // "Frequency" in Reminders app
    @State private var rate: Int = 1 // "Every" in Reminders App
    @State private var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @State private var reminderTime: Date? = nil // If it is not nil then a reminder has been set, else no reminder for
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {

                CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
                
                CreateEditHabitDetailContent(
                    goToAddDetailsSelection: goToAddDetailsSelection,
                    selectedDetails: $selectedDetails,
                    selectedColor: selectedColor
                )
                
                SchedulingContent(
                    schedulingUnits: $schedulingUnits,
                    rate: $rate,
                    scheduledWeekDays: $scheduledWeekDays,
                    reminderTime: $reminderTime,
                    goToScheduleSelection: goToScheduleSelection
                )
                
                CreateEditActivityCompletionGoalContent(
                    completionGoal: $completionGoal
                )
                
                Spacer()
                
//                HabitMePrimaryButton(
//                    title: "Create",
//                    isAbleToTap: isAbleToCreate,
//                    action: didTapButtonToCreateHabit
//                )
//                .padding(.horizontal)
            }
        }
        .createEditHabitSheetPresentation()
        .navigationTitle("New Habit")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    didTapButtonToCreateHabit()
                }
                .disabled(!isAbleToCreate)
            }
        }
//        .sheetyTopBarNav(title: "New Habit", dismissAction: { dismiss() })
//        .sheetyBottomBarButton(title: "Create", isAbleToTap: isAbleToCreate, action: didTapButtonToCreateHabit)
    }
    

    var isAbleToCreate: Bool {
        
        if selectedColor != nil && !nameTextFieldValue.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    /**
     * NOTE: I am inserting into the CoreDataStore because if I enter in SwiftData it will not propogate the change
     * to the NSFetchedResultsController that I am using on the HomeViewModel.
     * I do not need everything to be CoreData for now (like the selectedActivityDetails which are SwiftData entities)
     * so to speed things up I will leave that for now and just do a conversion here at the save point.
     */
    func didTapButtonToCreateHabit() {

        guard let selectedColor, let stringColorHex = selectedColor.toHexString() else {
            return
        }
        
        let habit = Habit(
            id: UUID().uuidString,
            name: nameTextFieldValue,
            creationDate: Date(),
            isArchived: false,
            goalCompletionsPerDay: completionGoal,
            color: stringColorHex,
            activityDetails: Set(selectedDetails),
            schedulingUnits: schedulingUnits,
            rate: rate,
            scheduledWeekDays: scheduledWeekDays,
            reminderTime: reminderTime
        )
        
        habitController.createHabit(habit)
        
        DispatchQueue.main.async {
            dismiss()
        }
    }
}


struct CreateEditHabitDetailContent: View {
    
    let goToAddDetailsSelection: (Binding<[ActivityDetail]>, Color?) -> Void
    @Binding var selectedDetails: [ActivityDetail]
    let selectedColor: Color?
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: .vSectionSpacing) {
                
            VStack(alignment: .leading) {
                HStack {
                    Text("Details")
                    Spacer()
                    CustomDisclosure()
                }
                
                Text("Extra Information to track with this habit")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            
            if !selectedDetails.isEmpty {
                LazyVStack(spacing: .vItemSpacing) {
                    ForEach($selectedDetails) { $detail in
                        let detail = $detail.wrappedValue
                        ActivityDetailSummaryRow(activityDetail: detail)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .onTapGesture {
            goToAddDetailsSelection($selectedDetails, selectedColor)
        }
    }
    
    
    func createHabitDetailView(detail: Binding<HabitDetail>) -> some View{
        
        HStack {
            TextField("Name", text: detail.name)
//                .focused($focusedDetail, equals: .row(id: detail.wrappedValue.id))
                .textFieldBackground()
                
            Picker("Type", selection: detail.valueType) {
                ForEach(ActivityDetailType.allCases) { type in
                    Text("\(type.rawValue)")
                }
            }
            .labelsHidden()
            
//            if detail.wrappedValue.valueType == .number {
//                Picker("Units", selection: detail.unit) {
//                    ForEach(DetailUnit.preloadedOptions, id: \.self) { detailUnit in
//                        Text("\(detailUnit.name)")
//                    }
//                }
////                .pickerStyle(.navigationLink)
//                .labelsHidden()
//            }
        }
    }
    
    
    private func removeRows(at offsets: IndexSet) {
        
        selectedDetails.remove(atOffsets: offsets)
    }
}


struct CreateEditHabitContent: View {
    
    @Binding var nameTextFieldValue: String
    @Binding var selectedColor: Color?
    
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 6)
    
    var body: some View {
        TextField("Name", text: $nameTextFieldValue)
            .textFieldBackground()
            .font(.headline)
            .padding(.horizontal)
        
        
        VStack {
            LazyVGrid(columns: columns, content: {
                ForEach(allColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .stroke(color, lineWidth: isColorSelected(color) ? 8 : 0)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            if isColorSelected(color) {
                                selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }
                }
            })
            .padding(.horizontal, 6)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    
    func isColorSelected(_ color: Color) -> Bool {
        
        selectedColor?.toHexString() == color.toHexString()
    }
    
    
    var allColors: [Color] {
        [
//            Color.red,
//            Color.orange,
//            Color.yellow,
//            Color.green,
//            Color.mint,
//            Color.teal,
//            
//            Color.cyan,
//            Color.blue,
//            Color.indigo,
//            Color.purple,
//            Color.pink,
//            Color.brown,
            
//            Color(hex: "#2eld74") ?? .pink, // black?
//            Color(hex: "#0000ff") ?? .pink, // blue
//            Color(hex: "#cldad6") ?? .pink, // black?
//            Color(hex: "#ff0000") ?? .pink, // red
            Color.pink,
            Color.red,
            Color(hex: "#f07857") ?? .pink, // bright rust
            Color(hex: "#9e444e") ?? .pink, // rust
            Color.brown,
            Color.orange,
            Color.yellow,
            Color(hex: "#ffd966") ?? .pink, // cream og - ffe6a8
            Color(hex: "#6ef790") ?? .pink, // pastel green og - 8bf8a7
            Color.green,
            Color(hex: "#73d016") ?? .pink, // green
            Color(hex: "#4fb06d") ?? .pink, // different green
            Color(hex: "#aebd0f") ?? .pink, // lime green og - d3e412
            Color(hex: "#728e3e") ?? .pink, // swamp green og - 556b2f
            Color(hex: "#09774b") ?? .pink, // forrest green og - 065535
            Color.mint,
            Color.teal,
            Color.cyan,
            Color(hex: "#6497ce") ?? .pink, // light blue - a6c3e3
            Color.blue,
            Color(hex: "#3333ff") ?? .pink, // navy blue og - 8clclc
            Color(hex: "#428cd7") ?? .pink, // purple gray og - 666999
            Color.indigo,
            Color.purple,
            Color(hex: "#9f91ee") ?? .pink, // lavender - og a89cf0
            Color(hex: "#a580b3") ?? .pink, // lavender gray? - og bdabc4
            Color(hex: "#b300b3") ?? .pink, // purple - og 800080
            Color(hex: "#be398d") ?? .pink, // deep pink/purple
            Color(hex: "#ef5fbe") ?? .pink, // pink
            Color(hex: "#fb9dca") ?? .pink, // light pink og - fdcfe5
//            Color(hex: "#4c516d") ?? .pink, // gray
//            Color(hex: "#ffff00") ?? .pink, // stupid bright yellow
//            Color(hex: "#ffd700") ?? .pink, // golden
//            Color(hex: "#0eff00") ?? .pink, // ninja turtle green
//            Color(hex: "#cbebcb") ?? .pink, // pastel green gray
//            Color(hex: "#43a5be") ?? .pink, // tealish?
//            Color(hex: "#53bdas") ?? .pink, // blue again
//            Color(hex: "#401e12") ?? .pink, // brown but really dark
//            Color(hex: "#808080") ?? .pink // gray
        ]
    }
}


struct HabitMeSheetDismissButton: View {
    
    let dismiss: () -> Void
    
    var body: some View {
        
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.navTitle)
        }
    }
}


struct FunButtonPressStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct HabitMePrimaryButton: View {
    
    let title: String
    let isAbleToTap: Bool
    let looksDisabled: Bool
    let color: Color
    let buttonWidth: CGFloat?
    let action: () -> Void
    
    init(title: String, isAbleToTap: Bool = true, looksDisabled: Bool = false, color: Color? = nil, buttonWidth: CGFloat? = nil, action: @escaping () -> Void) {
        
        self.title = title
        self.action = action
        self.color = color ?? .blue
        self.isAbleToTap = isAbleToTap
        self.buttonWidth = buttonWidth
        
        // Make sure this is true if actually disabled
        if !isAbleToTap {
            self.looksDisabled = true
        } else {
            self.looksDisabled = looksDisabled
        }
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: buttonWidth ?? .infinity)
                .frame(height: 50)
                .background(!looksDisabled ? color : color.opacity(0.5))
                .foregroundStyle(!looksDisabled ? Color.white : Color.white.opacity(0.5))
                .shadow(color: !looksDisabled ? .clear : .black.opacity(0.6), radius: 20)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(FunButtonPressStyle())
        .disabled(isAbleToTap == true ? false : true)
    }
}


#Preview {
    NavigationStack {
        CreateHabitView(
            blockHabitStore: CoreDataBlockHabitStore.preview(),
            goToAddDetailsSelection: { _, _ in }, 
            goToScheduleSelection: { _, _, _, _ in }
        )
    }
}
