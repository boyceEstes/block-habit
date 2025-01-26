//
//  DonationView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/8/24.
//

import SwiftUI
import StoreKit


let myDonationProductIdentifiers = [
    "com.boycees.HabitMePrototype.tinyTip",
    "com.boycees.HabitMePrototype.smallTip",
    "com.boycees.HabitMePrototype.mediumTip",
    "com.boycees.HabitMePrototype.largeTip"
]


struct TipItemView: View {
    
    @EnvironmentObject var store: TipStore
    let item: Product
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
                
            }
            
            Spacer()
            
            Button("\(item.displayPrice)"){
                Task {
                    await store.purchase(item)
                }
            }
                .tint(.blue)
                .buttonStyle(.bordered)
                .font(.callout.bold())
        }
        .padding(16)
        .background(Color(UIColor.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct DonationView: View {
    
    @EnvironmentObject private var store: TipStore
    // MARK: Injected Properties
    let didTapClose: () -> Void
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            HStack {
                Spacer()
                Button(action: didTapClose) {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }
            
            Text("Enjoying the app so far? 👀")
                .font(.system(.title2, design: .rounded).bold())
                .multilineTextAlignment(.center)
            
            Text("If you're enjoying the app and want to fuel my endless quest for better features (and fancier coffee), consider leaving a tip!")
            //  Who knew good code runs on caffeine and validation?
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            ForEach(store.items, id: \.self) { item in
                
                TipItemView(item: item)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(8)
        .overlay(alignment: .top) {
            Image("appIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
//                .padding(6)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .offset(y: -15)
        }
    }
}


#Preview {
    DonationView { }
        .environmentObject(TipStore())
}
