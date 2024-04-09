//
//  PortfolioItemView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/6/24.
//

import SwiftUI
import Combine

struct PortfolioItemView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(data.stock)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(String(data.quantity) + " shares")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing){
                Text("$" + String(format:"%.2f", data.marketValue))
                    .font(.headline)
                    .fontWeight(.bold)
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
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(data.change > 0 ? Color.green : data.change < 0 ? Color.red : Color.gray)
            }
        }
    }
}

extension PortfolioItemView {
    class ViewModel: ObservableObject {
        @Published var stock: String = ""
        @Published var marketValue: Double = 0
        @Published var quantity: Int = 0
        @Published var change: Double = 0
        @Published var changePercent: Double = 0
        
        init(stock: String, marketValue: Double, quantity: Int, change: Double, changePercent: Double) {
            self.stock = stock
            self.marketValue = marketValue
            self.quantity = quantity
            self.change = change
            self.changePercent = changePercent
        }
        
        init(d: PortfolioData) {
            self.stock = d.stock
            self.marketValue = d.marketValue
            self.quantity = d.quantity
            self.change = d.change
            self.changePercent = d.changePercent
        }
        
        //        @Published var a: Int = 0
        //        private var _b: Int = 0
        //        var b: Int {
        //            _b
        //        }
        //
        //        private var cancellables = Set<AnyCancellable>()
        //
        //        func caculateB() {
        //            $a.sink { [weak self] value in
        //                guard let strongSelf = self else { return }
        //                strongSelf._b = value * 2
        //            }
        //            .store(in: &cancellables)
        //        }
    }
}

extension PortfolioItemView.ViewModel: Hashable {
    static func == (lhs: PortfolioItemView.ViewModel, rhs: PortfolioItemView.ViewModel) -> Bool {
        return lhs.stock == rhs.stock &&
        lhs.marketValue == rhs.marketValue &&
        lhs.quantity == rhs.quantity &&
        lhs.change == rhs.change &&
        lhs.changePercent == rhs.changePercent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stock)
        hasher.combine(marketValue)
        hasher.combine(quantity)
        hasher.combine(change)
        hasher.combine(changePercent)
    }
}

#Preview {
    PortfolioItemView(data: PortfolioItemView.ViewModel(stock: "AAPL", marketValue: 514.8, quantity: 3, change: 0.39, changePercent: 0.08))
}
