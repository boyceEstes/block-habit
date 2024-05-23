//
//  ContentView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI
import HabitRepositoryFW


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


struct SplashView: View {
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            Image("appIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}


struct ContentView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    @State private var isTimeToShowContent = false
    
    let blockHabitStore: CoreDataBlockHabitStore
    
    
    // Home navigation
    @State var homeNavigationFlowPath = [HomeNavigationFlow.StackIdentifier]()
    @State var homeNavigationFlowDisplayedSheet: HomeNavigationFlow.SheetyIdentifier?
    
    // Habit Detail navigation
    @State var habitDetailNavigationFlowDisplayedSheet: HabitDetailNavigationFlow.SheetyIdentifier?
    
    // Create Habit navigation
    @State var createEditHabitNavigationFlowPath = [CreateEditHabitNavigationFlow.StackIdentifier]()
    
    // Add Details navigation
    @State var addDetailsNavigationFlowDisplayedSheet: AddDetailsNavigationFlow.SheetyIdentifier?
    
    var body: some View {
        
        Group {
            if isTimeToShowContent {
                makeHomeViewWithSheetyStackNavigation(blockHabitStore: blockHabitStore)
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                
                withAnimation {
                    self.isTimeToShowContent = true
                }
            }
        }
    }
}

/*
 * I want to ensure that I am bringing only going to turning off the loading screen when all the information is not empty
 */


#Preview {
    ContentView(blockHabitStore: CoreDataBlockHabitStore.preview())
}
