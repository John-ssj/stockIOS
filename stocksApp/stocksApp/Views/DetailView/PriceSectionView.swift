//
//  PriceSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct PriceSectionView: View {
    @ObservedObject var data: ViewModel
    
    init(data: ViewModel?) {
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(data.name)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            
            HStack {
                Text("$" + String(format:"%.2f", data.currentPrice))
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    if(data.change > 0) {
                        Image(systemName: "arrow.up.right")
                    } else if(data.change < 0) {
                        Image(systemName: "arrow.down.right")
                    } else {
                        Image(systemName: "minus")
                    }
                    Text("  $" + String(format:"%.2f", data.change))
                    Text("(" + String(format:"%.2f", data.changePercent) + "%)")
                }
                .lineLimit(1)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(data.change > 0 ? Color.green : data.change < 0 ? Color.red : Color.gray)
                
                Spacer()
            }
        }
    }
}

extension PriceSectionView {
    class ViewModel: ObservableObject {
        @Published var name: String = ""
        @Published var currentPrice: Double = 0
        @Published var change: Double = 0
        @Published var changePercent: Double = 0
        
        init() {}
        
        init(name: String, currentPrice: Double, change: Double, changePercent: Double) {
            self.name = name
            self.currentPrice = currentPrice
            self.change = change
            self.changePercent = changePercent
        }
        
        init(d: PriceData) {
            self.name = d.name
            self.currentPrice = d.lastPrice
            self.change = d.change
            self.changePercent = d.changePercent
        }
    }
}

#Preview {
    PriceSectionView(data: PriceSectionView.ViewModel(name: "AAPLE INC", currentPrice: 171.09, change: -7.58, changePercent: -4.24))
}
