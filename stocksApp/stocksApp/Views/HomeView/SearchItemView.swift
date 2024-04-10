//
//  SearchItemView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/9/24.
//

import SwiftUI

struct SearchItemView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data.stock)
                .font(.title3)
                .fontWeight(.bold)
            Text(data.name)
                .fontWeight(.medium)
                .foregroundColor(Color.gray)
        }
    }
}

extension SearchItemView {
    class ViewModel: ObservableObject {
        @Published var stock: String = ""
        @Published var name: String = ""
        
        init(stock: String, name: String) {
            self.stock = stock
            self.name = name
        }
        
        init(s: StockData) {
            self.stock = s.symbol
            self.name = s.description
        }
    }
}

extension SearchItemView.ViewModel: Hashable {
    static func == (lhs: SearchItemView.ViewModel, rhs: SearchItemView.ViewModel) -> Bool {
        return lhs.stock == rhs.stock &&
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stock)
        hasher.combine(name)
    }
}

#Preview {
    SearchItemView(data: SearchItemView.ViewModel(stock: "AAPL", name: "AAPLE INC"))
}
