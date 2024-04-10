//
//  HourlyPriceVariationChart.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct HourlyPriceVariationChart: View {
    @State var jsonString: String

    var body: some View {
        WebView(htmlFilename: "HourlyPriceVariationChart", data: jsonString)
            .edgesIgnoringSafeArea(.all)
            .frame(height: 320)
    }
}

#Preview {
    let jsonString = """
    {"stock":"AAPL","charts":[[1712592000000,168.57],[1712595600000,168.58],[1712599200000,168.71],[1712602800000,168.58],[1712606400000,168.45],[1712610000000,168.38],[1712613600000,167.49],[1712617200000,168.34],[1712649600000,168.3],[1712653200000,168.29],[1712656800000,168.03],[1712660400000,168.19],[1712664000000,168.47],[1712667600000,169.19],[1712671200000,169.34],[1712674800000,168.82],[1712678400000,169.05],[1712682000000,169.27],[1712685600000,168.64],[1712689200000,169.07],[1712692800000,169.65],[1712696400000,169.57],[1712700000000,169.65],[1712703600000,169.71]]}
    """
    return HourlyPriceVariationChart(jsonString: jsonString)
}
