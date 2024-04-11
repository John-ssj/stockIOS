//
//  TradeData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/11/24.
//

import Foundation

struct TradeData: Decodable {
    var wallet: Double
    var currentPrice: Double
    var quantity: Int
}
