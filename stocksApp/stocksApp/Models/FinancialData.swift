//
//  FinancialData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/9/24.
//

import Foundation

struct FinancialData: Decodable {
    var wallet: Double
    var portfolio: [PortfolioData]
    var watchList: [FavoriteData]
}

struct PortfolioData: Decodable {
    var stock: String
    var quantity: Int
    var marketValue: Double
    var change: Double
    var changePercent: Double
    var index: Int
}

struct FavoriteData: Decodable {
    var stock: String
    var name: String
    var currentPrice: Double
    var change: Double
    var changePercent: Double
    var index: Int
}
