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
