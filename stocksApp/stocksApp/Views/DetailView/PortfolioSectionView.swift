//
//  PortfolioSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct PortfolioSectionView: View {
    @ObservedObject var data: ViewModel
    
    init(data: ViewModel?) {
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Portfolio")
                .font(.title)
            
            HStack {
                if(data.shares > 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Shares Owned: ")
                                .fontWeight(.heavy)
                            Text(String(data.shares))
                                .fontWeight(.medium)
                        }
                        HStack {
                            Text("Avg. Cost / Share: ")
                                .fontWeight(.heavy)
                            Text("$" + String(format:"%.2f", data.avgCost))
                                .fontWeight(.medium)
                        }
                        HStack {
                            Text("Total Cost:")
                                .fontWeight(.heavy)
                            Text("$" + String(format:"%.2f", data.totalCost))
                                .fontWeight(.medium)
                        }
                        HStack {
                            Text("Change: ")
                                .fontWeight(.heavy)
                            Text("$" + String(format:"%.2f", data.change))
                                .fontWeight(.medium)
                                .foregroundColor(data.change > 0 ? Color.green : data.change < 0 ? Color.red : Color.gray)
                        }
                        HStack {
                            Text("Market Value: ")
                                .fontWeight(.heavy)
                            Text("$" + String(format:"%.2f", data.MarketValue))
                                .fontWeight(.medium)
                                .foregroundColor(data.change > 0 ? Color.green : data.change < 0 ? Color.red : Color.gray)
                        }
                    }
                    .font(.footnote)
                } else {
                    Text("You have 0 shares of " + data.stock + ".\nStart trading!")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: openTradeView, label: {
                    Text("Trade")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 50)
                        .background(Capsule().fill(Color.green))
                })
                
                Spacer()
            }
        }
    }
}

extension PortfolioSectionView {
    class ViewModel: ObservableObject {
        @Published var stock: String = ""
        @Published var shares: Int = 0
        @Published var avgCost: Double = 0
        @Published var totalCost: Double = 0
        @Published var change: Double = 0
        @Published var MarketValue: Double = 0
        
        init() {}
        
        init(stock: String ,shares: Int, avgCost: Double, totalCost: Double, change: Double, MarketValue: Double) {
            self.stock = stock
            self.shares = shares
            self.avgCost = avgCost
            self.totalCost = totalCost
            self.change = change
            self.MarketValue = MarketValue
        }
    }
}

extension PortfolioSectionView {
    func openTradeView() {
        print("Trade")
    }
}

#Preview {
    PortfolioSectionView(data: PortfolioSectionView.ViewModel(stock: "AAPL", shares: 3, avgCost: 171.23, totalCost: 513.69, change: -0.42, MarketValue: 513.27))
}
