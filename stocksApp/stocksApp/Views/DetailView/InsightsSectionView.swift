//
//  InsightsSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct InsightsSectionView: View {
    @ObservedObject var data: ViewModel
    
    init(data: ViewModel?) {
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Insights")
                .font(.title)
            
            HStack {
                Spacer()
                Text("Insider Sentiments")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aaple Inc")
                    Divider()
                    Text("Total")
                    Divider()
                    Text("Positive")
                    Divider()
                    Text("Negative")
                }
                .fontWeight(.heavy)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("MSPR")
                        .fontWeight(.heavy)
                    Divider()
                    Text(String(format:"%.2f", data.totalMspr))
                    Divider()
                    Text(String(format:"%.2f", data.positiveMspr))
                    Divider()
                    Text(String(format:"%.2f", data.negativeMspr))
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chaneg")
                        .fontWeight(.heavy)
                    Divider()
                    Text(String(format:"%.2f", data.totalChange))
                    Divider()
                    Text(String(format:"%.2f", data.positiveChange))
                    Divider()
                    Text(String(format:"%.2f", data.negativeChange))
                }
            }
            .font(.callout)
        }
    }
}

extension InsightsSectionView {
    class ViewModel: ObservableObject {
        @Published var totalMspr: Double = 0
        @Published var totalChange: Double = 0
        @Published var positiveMspr: Double = 0
        @Published var positiveChange: Double = 0
        @Published var negativeMspr: Double = 0
        @Published var negativeChange: Double = 0
        
        init() {}
        
        init(totalMspr: Double, totalChange: Double, positiveMspr: Double, positiveChange: Double, negativeMspr: Double, negativeChange: Double) {
            self.totalMspr = totalMspr
            self.totalChange = totalChange
            self.positiveMspr = positiveMspr
            self.positiveChange = positiveChange
            self.negativeMspr = negativeMspr
            self.negativeChange = negativeChange
        }
        
        init(d: InsightsData) {
            self.totalMspr = d.totalMspr
            self.totalChange = d.totalChange
            self.positiveMspr = d.positiveMspr
            self.positiveChange = d.positiveChange
            self.negativeMspr = d.negativeMspr
            self.negativeChange = d.negativeChange
        }
    }
}

#Preview {
    InsightsSectionView(data: InsightsSectionView.ViewModel(totalMspr: -654.26, totalChange: -3249586.00, positiveMspr: 200, positiveChange: 827822.00, negativeMspr: -883.52, negativeChange: -4077408))
}
