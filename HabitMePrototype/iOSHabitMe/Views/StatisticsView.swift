//
//  StatisticsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/27/24.
//

import SwiftUI

/*
 * To keep things as simple as I can think, I would want to keep this on the Home Screen and use
 * the existing Bar view on that screen. Interact with that bar view by tapping on filters which
 * would update the stats that will be displayed in this view.
 */

struct StatisticsView: View {
    var body: some View {
        Grid(alignment: .topLeading) {
            GridRow {
                StatBox(title: "Total Records", value: "150")
                StatBox(title: "Average Records / Day", value: "9.2", units: "rpd")
            }
            GridRow {
                StatBox(title: "Most Completions", value: "42", units: "records", subValue: "Journaling")
                StatBox(title: "Best Streak", value: "10", units: "days", subValue: "Meditation")
            }
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10)
         )
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    StatisticsView()
}
