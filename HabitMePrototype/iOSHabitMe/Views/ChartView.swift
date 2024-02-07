//
//  ChartView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/5/24.
//

import SwiftUI
import SwiftData
import Charts


struct TestingRecord: Identifiable {
    
    let id = UUID()
    let activityName: String
    let activityColor: String
    
    
    static let meditation = TestingRecord(activityName: "Meditation", activityColor: "orange")
    static let reading = TestingRecord(activityName: "Reading", activityColor: "pink")
    static let journaling = TestingRecord(activityName: "Journaling", activityColor: "yellow")
    static let studying = TestingRecord(activityName: "Studying", activityColor: "blue")
    static let cleaning = TestingRecord(activityName: "Cleaning", activityColor: "teal")
    static let drawing = TestingRecord(activityName: "Drawing", activityColor: "red")
}


struct LineChartActivityDetailData: Identifiable {
    
    let id = UUID()
    let date: Date
    let value: Double
    
    // Charts aren't great with dates until they are converted to strings
    var displayableDate: String {
        guard let noonDate = date.noon else { return "" }
        return DateFormatter.shortDate.string(from: noonDate)
    }
}

struct LineChartDateXAxisView: View {
    
    let data: [LineChartActivityDetailData]
//    
//    var initialXScrollPosition: String {
//        
//        guard let lastDataPoint = data.last else { return ""}
//        
//        return lastDataPoint.displayableDate
//    }
    
    var body: some View {
        
        Chart {
            ForEach(data) { lineMarkData in
                
                LineMark(
                    x: .value("Date", lineMarkData.displayableDate),
                    y: .value("Amount", lineMarkData.value)
                )
            }
        }
        .frame(height: 150)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 8)
//        .chartScrollPosition(initialX: initialXScrollPosition)
    }
    
    
//    var lowestValue:
}


struct BarChartView: View {
    
    let datesWithTestRecords: [Date: [TestingRecord]] = [
        Date().adding(days: -10): [.journaling, .meditation, .reading],
        Date().adding(days: -9): [.reading],
        Date().adding(days: -8): [.journaling, .reading],
        Date().adding(days: -7): [.journaling, .drawing, .reading, .reading, .reading, .reading, .reading, .reading, .reading, .reading, .journaling],
        Date().adding(days: -6): [.journaling, .studying, .reading],
        Date().adding(days: -5): [.journaling, .meditation, .reading],
        Date().adding(days: -4): [.journaling, .reading],
        Date().adding(days: -3): [.journaling, .studying, .reading],
        Date().adding(days: -2): [.journaling, .meditation, .reading],
        Date().adding(days: -1): [.journaling, .drawing],
        Date(): [.journaling]
    ]


    var body: some View {
        VStack {
//            ScrollView(.horizontal) {
//                LazyHStack {
                    Chart {
                        ForEach(datesWithTestRecords.sorted(by: { $0.key < $1.key }), id: \.key) { date, testRecords in

                            ForEach(testRecords) { testRecord in
                                BarMark(
                                    x: .value("Date", DateFormatter.shortDate.string(from: date)),
                                    y: .value("Something", 1),
                                    width: 40
                                )
                                .foregroundStyle(by: .value("Shape Color", testRecord.activityColor))
                            }
                        }
                    }
//                    .chartYScale(domain: [0, 8])
                    .chartScrollableAxes(.horizontal)
                    .frame(height: 300)
//                }
                .background(Color.red)
//            }
            Text("There is some data above")
            Spacer()
        }
        .background(Color.yellow)
    }
}

#Preview {
 
    // Detail value could be anything. Could be weight, duratino in minutes, etc. no colors on line graph
    let data = [
        LineChartActivityDetailData(date: Date().adding(days: -1), value: 192.5),
        LineChartActivityDetailData(date: Date().adding(days: -2), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -3), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -4), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -5), value: 187.3),
        LineChartActivityDetailData(date: Date().adding(days: -6), value: 189.2),
        LineChartActivityDetailData(date: Date().adding(days: -7), value: 188.6),
        LineChartActivityDetailData(date: Date().adding(days: -8), value: 192.5),
        LineChartActivityDetailData(date: Date().adding(days: -9), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -10), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -11), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -12), value: 187.3),
        LineChartActivityDetailData(date: Date().adding(days: -13), value: 189.2),
        LineChartActivityDetailData(date: Date().adding(days: -14), value: 188.6),
        LineChartActivityDetailData(date: Date().adding(days: -15), value: 300.23),
        LineChartActivityDetailData(date: Date().adding(days: -16), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -17), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -18), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -19), value: 187.3),
        LineChartActivityDetailData(date: Date().adding(days: -20), value: 189.2),
        LineChartActivityDetailData(date: Date().noon!, value: 300)
    ]
    
    return LineChartDateXAxisView(data: data)
}
