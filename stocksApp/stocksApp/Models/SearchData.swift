//
//  SearchData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/9/24.
//

import Foundation

struct SearchData: Decodable {
    var stocks: [StockData]
}

struct StockData: Decodable {
    var symbol: String
    var description: String
}
