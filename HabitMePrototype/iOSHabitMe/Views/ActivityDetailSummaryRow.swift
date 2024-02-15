//
//  ActivityDetailSummaryRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/10/24.
//

import SwiftUI

struct ActivityDetailSummaryRow: View {
    
    let activityDetail: ActivityDetail
    
    var body: some View {
        
        ActivityDetailBasicInfo(activityDetail: activityDetail)
        .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
    }
}


struct ActivityDetailBasicInfo: View {
    
    let activityDetail: ActivityDetail
    
    var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline) {
                Text("\(activityDetail.name)")
                if let units = activityDetail.units {
                    Text("in \(units)")
                        .foregroundStyle(Color.secondaryFont)
                }
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
