//
//  FavoriteData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/6/24.
//

import Foundation

struct FavoriteData: Decodable {
    var stock: String
    var name: String
    var currentPrice: Double
    var change: Double
    var changePercent: Double
    var index: Int
}
