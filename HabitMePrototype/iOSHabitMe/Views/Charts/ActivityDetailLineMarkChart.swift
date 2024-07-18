//
//  ActivityDetailLineMarkChart.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/8/24.
//

import SwiftUI
import Charts

/// Need to make completely sure that the content HAS data before this is called or it will give an error
struct ActivityDetailLineMarkChart: View {
    
    let xVisibleDomainLength = 8
    
    let data: [LineChartActivityDetailData]
    let lineColor: Color
    
    /// For things like weight that might not change very drastically, we want to give the option to make the graph's range smaller to see changes easier.
    let isFocusedDomain: Bool
    
    var focusedDomain: ClosedRange<Int>? {
        data.focusedDomainRange()
    }
    

    var initialXScrollPosition: String {
        
        guard let index = data.index(data.endIndex, offsetBy: -xVisibleDomainLength, limitedBy: data.startIndex) else {
            return data[data.startIndex].displayableDate
        }
        
        return data[index].displayableDate
    }
    
    
//    var focusedDomain
    
    var gradientColor: LinearGradient
    
    init(
        data: [LineChartActivityDetailData],
        lineColor: Color,
        isFocusedDomain: Bool
    ) {
        
        self.data = data
        self.lineColor = lineColor
        self.isFocusedDomain = isFocusedDomain
        
        self.gradientColor = LinearGradient(
            gradient: Gradient(
                colors: [
                    lineColor.opacity(0.5),
                    lineColor.opacity(0.2),
                    lineColor.opacity(0.05)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    
    var body: some View {
        
        Chart {
            ForEach(data) { lineMarkData in
                
                LineMark(
                    x: .value("Date", lineMarkData.displayableDate),
                    y: .value("Amount", lineMarkData.value)
                )
                .interpolationMethod(.catmullRom) // Makes it sloping and fun
                .symbol {
                    Circle()
                        .fill(lineColor)
                        .frame(width: 5)
                }
                .symbolSize(30)
                .foregroundStyle(lineColor)
                

                AreaMark(
                    x: .value("Date", lineMarkData.displayableDate),
                    y: .value("Amount", lineMarkData.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(gradientColor)
            }
        }
        .frame(height: 150)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: xVisibleDomainLength)
        // zooms in for stats that need to be focused
        .if(isFocusedDomain && focusedDomain != nil) { view in
            view.chartYScale(domain: focusedDomain!)
        }
        .chartScrollPosition(initialX: initialXScrollPosition)
    }
    
    
//    var lowestValue:
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


#Preview {
    
    let data = [
        LineChartActivityDetailData(date: Date().adding(days: -19), value: 192.5),
        LineChartActivityDetailData(date: Date().adding(days: -18), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -17), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -16), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -15), value: 187.3),
        LineChartActivityDetailData(date: Date().adding(days: -14), value: 189.2),
        LineChartActivityDetailData(date: Date().adding(days: -13), value: 188.6),
        LineChartActivityDetailData(date: Date().adding(days: -12), value: 192.5),
        LineChartActivityDetailData(date: Date().adding(days: -11), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -10), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -9), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -8), value: 187.3),
        LineChartActivityDetailData(date: Date().adding(days: -7), value: 189.2),
        LineChartActivityDetailData(date: Date().adding(days: -6), value: 188.6),
        LineChartActivityDetailData(date: Date().adding(days: -5), value: 300.23),
        LineChartActivityDetailData(date: Date().adding(days: -4), value: 188.3),
        LineChartActivityDetailData(date: Date().adding(days: -3), value: 186.8),
        LineChartActivityDetailData(date: Date().adding(days: -2), value: 187.0),
        LineChartActivityDetailData(date: Date().adding(days: -1), value: 187.3),
        LineChartActivityDetailData(date: Date().noon!, value: 300)
    ]
    
    
    return VStack {
        ActivityDetailLineMarkChart(data: data, lineColor: .red, isFocusedDomain: false)
        ActivityDetailLineMarkChart(data: data, lineColor: .red, isFocusedDomain: true)
    }
}
