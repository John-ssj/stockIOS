//
//  PortfolioData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/6/24.
//

import Foundation

struct PortfolioData: Decodable {
    var stock: String
    var quantity: Int
    var marketValue: Double
    var change: Double
    var changePercent: Double
    var index: Int
}
