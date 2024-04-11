//
//  RecommendationTrendsChart.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct RecommendationTrendsChart: View {
    @State var jsonString: String
    
    var body: some View {
        WebView(htmlFilename: "RecommendationTrendsChart", data: jsonString)
            .edgesIgnoringSafeArea(.all)
            .frame(height: 370)
    }
}

#Preview {
    let jsonString = """
    {
        "period": ["2024-04", "2024-03", "2024-02", "2024-01"],
        "buy": [20, 20, 19, 22],
        "hold": [14, 14, 13, 13],
        "sell": [2, 2, 2, 1],
        "strongBuy": [11, 12, 12, 12],
        "strongSell": [0, 0, 0, 0]
    }
    """
    return RecommendationTrendsChart(jsonString: jsonString)
}
