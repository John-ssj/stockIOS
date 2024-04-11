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
    var datetime: Date
    var summary: String
    var url: String
    
    var id: String { url }
    
    enum CodingKeys: String, CodingKey {
        case imgUrl, headline, source, datetime, summary, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        imgUrl = try container.decode(String.self, forKey: .imgUrl)
        headline = try container.decode(String.self, forKey: .headline)
        source = try container.decode(String.self, forKey: .source)
        let timestamp = try container.decode(Int.self, forKey: .datetime)
        datetime = Date(timeIntervalSince1970: TimeInterval(timestamp))
        summary = try container.decode(String.self, forKey: .summary)
        url = try container.decode(String.self, forKey: .url)
    }
    
    init(imgUrl: String, headline: String, source: String, datetime: Date, summary: String, url: String) {
        self.imgUrl = imgUrl
        self.headline = headline
        self.source = source
        self.datetime = datetime
        self.summary = summary
        self.url = url
    }
}

struct DetailPortfolioData: Decodable {
    var favorite: Bool
    var stock: String
    var name: String
    var quantity: Int
    var avgCost: Double
    var totalCost: Double
    var change: Double
    var marketValue: Double
}
