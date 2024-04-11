//
//  HistoricalEPSChart.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct HistoricalEPSChart: View {
    @State var jsonString: String
    
    var body: some View {
        WebView(htmlFilename: "HistoricalEPSChart", data: jsonString)
            .edgesIgnoringSafeArea(.all)
            .frame(height: 370)
    }
}

#Preview {
    let jsonString = """
    {
        "periodAndSurprise": [
            "2023-12-31<br>surprise: 0.0399",
            "2023-09-30<br>surprise: 0.0406",
            "2023-06-30<br>surprise: 0.0417",
            "2023-03-31<br>surprise: 0.0577"
        ],
        "actual": [
            2.18,
            1.46,
            1.26,
            1.52
        ],
        "estimate": [
            2.1401,
            1.4194,
            1.2183,
            1.4623
        ]
    }
    """
    return HistoricalEPSChart(jsonString: jsonString)
}
