//
//  ActivityDetailLineMarkChart.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/8/24.
//

import SwiftUI
import Charts


struct ActivityDetailLineMarkChart: View {
    
    let xVisibleDomainLength = 8
    
    let data: [LineChartActivityDetailData]
    let lineColor: Color

    var initialXScrollPosition: String {
        
        guard let index = data.index(data.endIndex, offsetBy: -xVisibleDomainLength, limitedBy: data.startIndex) else {
            return data[data.startIndex].displayableDate
        }
        
        return data[index].displayableDate
    }
    
    var gradientColor: LinearGradient
    
    init(data: [LineChartActivityDetailData], lineColor: Color) {
        self.data = data
        self.lineColor = lineColor
        
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
        .chartScrollPosition(initialX: initialXScrollPosition)
    }
    
    
//    var lowestValue:
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
    
    
    return ActivityDetailLineMarkChart(data: data, lineColor: .red)
}
