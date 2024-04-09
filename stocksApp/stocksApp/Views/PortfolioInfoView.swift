//
//  PortfolioInfoView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/6/24.
//

import SwiftUI

struct PortfolioInfoView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("Net Worth")
                    .font(.title3)
                    .fontWeight(.regular)
                Text("$" + String(format:"%.2f", data.worth))
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .leading){
                Text("Cash Balance")
                    .font(.title3)
                    .fontWeight(.regular)
                Text("$" + String(format:"%.2f", data.balance))
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
    }
}

extension PortfolioInfoView {
    class ViewModel: ObservableObject {
        @Published var worth: Double = 0
        @Published var balance: Double = 0
        
        init(worth: Double, balance: Double) {
            self.worth = worth
            self.balance = balance
        }
    }
}

#Preview {
    PortfolioInfoView(data: PortfolioInfoView.ViewModel(worth: 25000, balance: 25000))
}
