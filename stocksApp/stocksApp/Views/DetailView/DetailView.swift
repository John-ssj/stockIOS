//
//  DetailView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/9/24.
//

import SwiftUI
import Alamofire

struct DetailView: View {
    @ObservedObject var data: ViewModel
    @State var showToast = false
    @State var toastMessage = ""
    
    init(stock: String) {
        self.data = ViewModel(stock: stock)
    }
    
    var body: some View {
        if(data.loadDate) {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Fetching Data...")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            .onAppear(perform: {
                data.getDataFromServer()
            })
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20.0) {
                    PriceSectionView(data: data.priceInfo)
                    
                    ChartsTabView(hourlyChartJson: data.hourlyChartInfo, historicalSMAChartJson: data.SMAChartInfo)
                    
                    PortfolioSectionView(data: data.portfolioInfo)
                    
                    StatsSectionView(data: data.statsInfo)
                    
                    AboutSectionView(data: data.aboutInfo)
                    
                    InsightsSectionView(data: data.insightsInfo)
                    
                    RecommendationTrendsChart(jsonString: data.recommendChartInfo)
                    
                    HistoricalEPSChart(jsonString: data.EPSChartInfo)
                    
                    NewsSectionView(data: data.newsInfo)
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle(data.stock)
            .toolbar {
                Button {
                    AddRemoveFavorite()
                } label: {
                    if(data.favorite) {
                        Image(systemName: "plus.circle.fill")
                    }else {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .toast(isPresented: $showToast) {
                Text(toastMessage)
                    .foregroundColor(Color.white)
            }
        }
    }
}

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var stock: String
        // TODO: - loadDate改成true
        @Published var loadDate = true
        @Published var favorite = false
        @Published var priceInfo: PriceSectionView.ViewModel?
        @Published var portfolioInfo: PortfolioSectionView.ViewModel?
        @Published var statsInfo: StatsSectionView.ViewModel?
        @Published var aboutInfo: AboutSectionView.ViewModel?
        @Published var insightsInfo: InsightsSectionView.ViewModel?
        @Published var newsInfo: NewsSectionView.ViewModel?
        @Published var hourlyChartInfo: String = ""
        @Published var SMAChartInfo: String = ""
        @Published var recommendChartInfo: String = ""
        @Published var EPSChartInfo: String = ""
        
        init(stock: String) {
            self.stock = stock
        }
        
        func getDataFromServer() {
            print("startgetData-DetailView: ", stock)
            AF.request(serverUrl + "/stock/company?symbol=" + stock).responseDecodable(of: DetailData.self) { response in
                switch response.result {
                case .success(let detailData):
                    self.favorite = detailData.portfolio.favorite
                    self.priceInfo = PriceSectionView.ViewModel(d: detailData.price)
                    self.portfolioInfo = PortfolioSectionView.ViewModel(d: detailData.portfolio)
                    self.statsInfo = StatsSectionView.ViewModel(d: detailData.stats)
                    self.aboutInfo = AboutSectionView.ViewModel(d: detailData.about)
                    print("detailData.news", detailData.news.count)
                    self.newsInfo = NewsSectionView.ViewModel(d: detailData.news)
                    self.insightsInfo = InsightsSectionView.ViewModel(d: detailData.insights)
                    self.hourlyChartInfo = detailData.hourlyChart
                    self.SMAChartInfo = detailData.SMACharts
                    self.recommendChartInfo = detailData.recommendCharts
                    self.EPSChartInfo = detailData.EPSCharts
                    self.loadDate = false
                case .failure(let error):
                    print("Error while fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension DetailView {
    func AddRemoveFavorite() {
        let addRemoveFavoriteUrl = serverUrl + "/financial/" + (data.favorite ? "removeWatchList" : "addWatchList") + "?symbol=" + data.stock
        data.favorite.toggle()
        AF.request(addRemoveFavoriteUrl).response{ response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                self.showToast = true
                                self.toastMessage = data.favorite ? ("Adding " + data.stock + " to Favorites") : ("Removing " + data.stock + " from Favorites")
                                return
                            }
                        }
                    } catch { }
                }
                self.showToast = true
                self.toastMessage = data.favorite ? ("Failed to add " + data.stock + " to Favorites") : ("Failed to remove " + data.stock + " from Favorites")
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    DetailView(stock: "AAPL")
}
