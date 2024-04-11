//
//  PortfolioSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI
import Alamofire

struct PortfolioSectionView: View {
    @ObservedObject var data: ViewModel
    @State private var isTrading: Bool = false
    
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
                            Text("$" + String(format:"%.2f", data.marketValue))
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
                
                
                Button {
                    isTrading = true
                } label: {
                    Text("Trade")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 50)
                        .background(Capsule().fill(Color.green))
                }
                .onChange(of: isTrading) { oldValue, newValue in
                    if(newValue == false) {
                        print("update portfolio")
                        data.getDataFromServer()
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isTrading, content: {
            TradeView(isTrading: $isTrading, stock: data.stock, name: data.name)
        })
    }
}

extension PortfolioSectionView {
    class ViewModel: ObservableObject {
        @Published var stock: String = ""
        @Published var name: String = ""
        @Published var shares: Int = 0
        @Published var avgCost: Double = 0
        @Published var totalCost: Double = 0
        @Published var change: Double = 0
        @Published var marketValue: Double = 0
        
        init() {}
        
        init(stock: String ,name: String ,shares: Int, avgCost: Double, totalCost: Double, change: Double, marketValue: Double) {
            self.stock = stock
            self.name = name
            self.shares = shares
            self.avgCost = avgCost
            self.totalCost = totalCost
            self.change = change
            self.marketValue = marketValue
        }
        
        init(d: DetailPortfolioData) {
            self.stock = d.stock
            self.name = d.name
            self.shares = d.quantity
            self.avgCost = d.avgCost
            self.totalCost = d.totalCost
            self.change = d.change
            self.marketValue = d.marketValue
        }
        
        func getDataFromServer() {
            print("startgetData-PortfolioSectionView: ", stock)
            AF.request(serverUrl + "/financial/getInfo?symbol=" + stock).responseDecodable(of: DetailPortfolioData.self) { response in
                switch response.result {
                case .success(let portfolioData):
                    self.shares = portfolioData.quantity
                    self.avgCost = portfolioData.avgCost
                    self.totalCost = portfolioData.totalCost
                    self.change = portfolioData.change
                    self.marketValue = portfolioData.marketValue
                case .failure(let error):
                    print("Error while fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    PortfolioSectionView(data: PortfolioSectionView.ViewModel(stock: "AAPL", name: "Apple Inc", shares: 3, avgCost: 171.23, totalCost: 513.69, change: -0.42, marketValue: 513.27))
}
