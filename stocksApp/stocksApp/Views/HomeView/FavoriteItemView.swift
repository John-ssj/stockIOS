//
//  FavoriteItemView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/6/24.
//

import SwiftUI

struct FavoriteItemView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(data.stock)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(String(data.name))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 120.0, alignment: .leading)
            }
            
            Spacer()
            
            VStack(alignment: .trailing){
                Text("$" + String(format:"%.2f", data.currentPrice))
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
                    Text("  $\(String(format:"%.2f", data.change)) (\(String(format:"%.2f", data.changePercent))%)")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(data.change > 0 ? Color.green : data.change < 0 ? Color.red : Color.gray)
            }
        }
    }
}

extension FavoriteItemView {
    class ViewModel: ObservableObject {
        @Published var stock: String  = ""
        @Published var name: String = ""
        @Published var currentPrice: Double = 0
        @Published var change: Double = 0
        @Published var changePercent: Double = 0
        
        init(stock: String, name: String, currentPrice: Double, change: Double, changePercent: Double) {
            self.stock = stock
            self.name = name
            self.currentPrice = currentPrice
            self.change = change
            self.changePercent = changePercent
        }
        
        init(d: FavoriteData) {
            self.stock = d.stock
            self.name = d.name
            self.currentPrice = d.currentPrice
            self.change = d.change
            self.changePercent = d.changePercent
        }
    }
}

extension FavoriteItemView.ViewModel: Hashable {
    static func == (lhs: FavoriteItemView.ViewModel, rhs: FavoriteItemView.ViewModel) -> Bool {
        return lhs.stock == rhs.stock &&
               lhs.name == rhs.name &&
               lhs.currentPrice == rhs.currentPrice &&
               lhs.change == rhs.change &&
               lhs.changePercent == rhs.changePercent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stock)
        hasher.combine(name)
        hasher.combine(currentPrice)
        hasher.combine(change)
        hasher.combine(changePercent)
    }
}

#Preview {
    FavoriteItemView(data: FavoriteItemView.ViewModel(stock: "AAPL", name: "Apple Inc", currentPrice: 171.44, change: -7.23, changePercent: -4.05))
}
