//
//  DetailData.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/11/24.
//

import Foundation

struct DetailData: Decodable {
    var price: PriceData
    var stats: StatsData
    var about: AboutData
    var news: [NewsItemData]
    var insights: InsightsData
    var portfolio: DetailPortfolioData
    var hourlyChart: String
    var SMACharts: String
    var recommendCharts: String
    var EPSCharts: String
}

struct PriceData: Decodable {
    var name: String
    var lastPrice: Double
    var change: Double
    var changePercent: Double
}

struct StatsData: Decodable {
    var highPrice: Double
    var lowPrice: Double
    var openPrice: Double
    var prevClose: Double
}

struct AboutData: Decodable {
    var ipo: String
    var industry: String
    var webpage: String
    var peers: [String]
}

struct InsightsData: Decodable {
    var totalMspr: Double
    var positiveMspr: Double
    var negativeMspr: Double
    var totalChange: Double
    var positiveChange: Double
    var negativeChange: Double
}

struct NewsItemData: Decodable, Identifiable {
    var imgUrl: String
    var headline: String
    var source: String
    var datetime: String
    var summary: String
    var url: String
    
    var id: String { url }
}

struct DetailPortfolioData: Decodable {
    var favorite: Bool
    var stock: String
    var quantity: Int
    var avgCost: Double
    var totalCost: Double
    var change: Double
    var marketValue: Double
}
