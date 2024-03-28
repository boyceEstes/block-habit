//
//  CreateHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI



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
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let blockHabitStore: CoreDataBlockHabitStore
    let goToAddDetailsSelection: (Binding<[ActivityDetail]>, Color?) -> Void
    
    @State private var nameTextFieldValue: String = ""
    @State private var selectedColor: Color? = nil
    @State private var selectedDetails = [ActivityDetail]()
    @State private var completionGoal: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                CreateEditHabitContent(nameTextFieldValue: $nameTextFieldValue, selectedColor: $selectedColor)
                
                CreateEditHabitDetailContent(
                    goToAddDetailsSelection: goToAddDetailsSelection,
                    selectedDetails: $selectedDetails,
                    selectedColor: selectedColor
                )
                
                CreateEditActivityCompletionGoalContent(
                    completionGoal: $completionGoal
                )
            }
        }
        .createEditHabitSheetPresentation()
        .sheetyTopBarNav(title: "New Habit", dismissAction: { dismiss() })
        .sheetyBottomBarButton(title: "Create", isAbleToTap: isAbleToCreate, action: didTapButtonToCreateHabit)
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
        
        Task {
            do {
                guard let selectedColor, let stringColorHex = selectedColor.toHexString() else {
                    return
                }
                
                let habit = Habit(
                    id: UUID().uuidString,
                    name: nameTextFieldValue,
                    isArchived: false,
                    goalCompletionsPerDay: completionGoal,
                    color: stringColorHex,
                    activityDetails: selectedDetails
                )
                
                try await blockHabitStore.create(habit)
                
                DispatchQueue.main.async {
                    dismiss()
                }
                
            } catch {
                // FIXME: Handle errors with saving to core data
                fatalError("FAILED MISERABLY TO CREATE HABIT - \(error)")
            }
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
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
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
    
//    var body: some View {
//        List {
//            
//            Section {
//                
//                ForEach($details) { $detail in
//                    
//                    createHabitDetailView(detail: $detail)
//                }
//                .onDelete(perform: removeRows)
//            } header: {
//                HStack {
//                    Text("Details")
//                    Spacer()
//                    Button {
//                        print("Add")
////                        let newHabitDetail = HabitDetail(name: "", valueType: .number, unit: DetailUnit.none)
////                        details.append(newHabitDetail)
////                        focusedDetail = .row(id: newHabitDetail.id)
//                        goToAddDetailsSelection()
//                    } label: {
//                        Image(systemName: "plus.circle")
//                            .foregroundStyle(.blue)
//                    }
//                    .font(.title3)
//                }
//            } footer: {
//                Text("Extra information to track when this habit is completed.\n\nExample: 'Duration: 20 min' ")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//            }
//        }
//        .scrollDisabled(true)
//        .scrollContentBackground(.hidden)
//    }
    
    
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
    
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        TextField("Name", text: $nameTextFieldValue)
            .textFieldBackground()
            .font(.headline)
            .padding(.horizontal)
        
        
        VStack {
            LazyHGrid(rows: rows, spacing: 30) {
                ForEach(allColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .stroke(Color.white, lineWidth: isColorSelected(color) ? 2 : 0)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            if isColorSelected(color) {
                                selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }
                }
            }
            .frame(height: 90)
        }
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
            Color.red,
            Color.orange,
            Color.yellow,
            Color.green,
            Color.mint,
            Color.teal,
            
            Color.cyan,
            Color.blue,
            Color.indigo,
            Color.purple,
            Color.pink,
            Color.brown
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
    let color: Color
    let buttonWidth: CGFloat?
    let action: () -> Void
    
    init(title: String, isAbleToTap: Bool = true, color: Color? = nil, buttonWidth: CGFloat? = nil, action: @escaping () -> Void) {
        
        self.title = title
        self.action = action
        self.color = color ?? .blue
        self.isAbleToTap = isAbleToTap
        self.buttonWidth = buttonWidth
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: buttonWidth ?? .infinity)
                .frame(height: 50)
                .background(isAbleToTap ? color : color.opacity(0.5))
                .foregroundStyle(isAbleToTap ? Color.white : Color.white.opacity(0.5))
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
            goToAddDetailsSelection: { _, _ in }
        )
    }
}
