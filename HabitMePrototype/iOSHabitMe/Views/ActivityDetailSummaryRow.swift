//
//  ActivityDetailSummaryRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/10/24.
//

import SwiftUI
import HabitRepositoryFW

struct ActivityDetailSummaryRow: View {
    
    let activityDetail: ActivityDetail
    
    var body: some View {
        
        ActivityDetailBasicInfo(activityDetail: activityDetail)
        .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
    }
}


struct ActivityDetailBasicInfo: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let activityDetail: ActivityDetail
    
    var body: some View {
        HStack {
            if dynamicTypeSize >= .accessibility1 {
                VStack(alignment: .leading) {
                    Text("\(activityDetail.name)")
                        
                    
                    let prettyUnits = activityDetail.prettyUnits()
                    if !prettyUnits.isEmpty {
                        Text("\(prettyUnits)")
                            .foregroundStyle(Color.secondaryFont)
                    }
                }
                .lineLimit(2)
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(activityDetail.name)")
                    
                    let prettyUnits = activityDetail.prettyUnits()
                    if !prettyUnits.isEmpty {
                        Text("\(prettyUnits)")
                            .foregroundStyle(Color.secondaryFont)
                    }
                }
                .lineLimit(1)
            }

            
            Spacer()
            
            activityDetail.valueType.asset.image()
        }
    }
}


#Preview {
    
    VStack {
        ActivityDetailSummaryRow(activityDetail: .amount)
        ActivityDetailSummaryRow(activityDetail: .note)
    }
    .sectionBackground()
}
