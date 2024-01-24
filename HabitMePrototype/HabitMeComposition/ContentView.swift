//
//  ContentView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI


enum SpecialHabitError: Error {
    
}

extension Date {
    var noon: Date? {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(uiColor: .darkGray))
//                .stroke(Color.blue, lineWidth: 1)
        ).padding()
    }
}


struct ContentView: View {
    
    var body: some View {
        
        NavigationStack {
            HomeView()
        }
    }
}


class AppState {
    
    static let shared = AppState()
    
    private init() {}
    
    private(set) var selectedDate = Date().noon!
    
    func setSelectedDateToNext() {
        
        print("Go forward in time unless its today")
    }
    
    func setSelectedDateToPrevious() {
        
        print("Go back in time")
        
    }
}




#Preview {
    ContentView()
}
