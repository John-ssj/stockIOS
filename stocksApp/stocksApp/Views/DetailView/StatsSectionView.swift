//
//  StatsSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct StatsSectionView: View {
    @ObservedObject var data: ViewModel
    
    init(data: ViewModel?) {
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.title)
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("High Price: ")
                            .fontWeight(.heavy)
                        Text("$" + String(format:"%.2f", data.highPrice))
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("Low Price: ")
                            .fontWeight(.heavy)
                        Text("$" + String(format:"%.2f", data.lowPrice))
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Open Price: ")
                            .fontWeight(.heavy)
                        Text("$" + String(format:"%.2f", data.openPrice))
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("Prev. Close: ")
                            .fontWeight(.heavy)
                        Text("$" + String(format:"%.2f", data.closePrice))
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
            .font(.footnote)
        }
    }
}

extension StatsSectionView {
    class ViewModel: ObservableObject {
        @Published var highPrice: Double = 0
        @Published var lowPrice: Double = 0
        @Published var openPrice: Double = 0
        @Published var closePrice: Double = 0
        
        init() {}
        
        init(highPrice: Double, lowPrice: Double, openPrice: Double, closePrice: Double) {
            self.highPrice = highPrice
            self.lowPrice = lowPrice
            self.openPrice = openPrice
            self.closePrice = closePrice
        }
        
        init(d: StatsData) {
            self.highPrice = d.highPrice
            self.lowPrice = d.lowPrice
            self.openPrice = d.openPrice
            self.closePrice = d.prevClose
        }
    }
}

#Preview {
    StatsSectionView(data: StatsSectionView.ViewModel(highPrice: 177.49, lowPrice: 170.85, openPrice: 177.00, closePrice: 178.67))
}
