//
//  NewsSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct NewsSectionView: View {
    @ObservedObject var data: ViewModel
    @State private var selectedNews: NewsItemData? = nil
    
    init(data: ViewModel?) {
        print(data?.newsData.count)
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("News")
                .font(.title)
            
            ForEach(data.newsData.indices, id: \.self) { index in
                if index == 0 {
                    NewsMainItemView(data: NewsMainItemView.ViewModel(d: data.newsData[index]))
                        .onTapGesture {
                            self.selectedNews = data.newsData[index]
                        }
                    if(data.newsData.count > 1) {
                        Divider()
                    }
                } else {
                    NewsItemView(data: NewsItemView.ViewModel(d: data.newsData[index]))
                        .onTapGesture {
                            self.selectedNews = data.newsData[index]
                        }
                }
            }
        }
        .sheet(item: $selectedNews) { news in
            NewsDetailView(selectedNews: $selectedNews, data: NewsDetailView.ViewModel(d: news))
        }
    }
}

extension NewsSectionView {
    class ViewModel: ObservableObject {
        @Published var newsData: [NewsItemData] = []
        
        init() {}
        
        init(d: [NewsItemData]) {
            self.newsData = d
        }
    }
}

#Preview {
    NewsSectionView(data: NewsSectionView.ViewModel(d: [
        NewsItemData(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks Are Moving the Most Today: Nvidia, Delta, Taiwan Semiconductor, PriceSmart, WD-40, and More", source: "Yahoo", datetime: "April 10, 2024", summary: "Nvidia stock slips after shares enter a correction, Delta is scheduled to report first-quarter earnings, and Taiwan Semiconductor posts strong quarterly sales.", url: "https://finnhub.io/api/news?id=aa78361f5e07292fb6dd0b671afdf0179c5becd8eb0b46810d34d5270ec72c26"),
        NewsItemData(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks and More These Stocks and More These Stocks and More", source: "Yahoo", datetime: "April 10, 2024", summary: "Nvidia stock slips after shares enter a correction, Delta is scheduled to report first-quarter earnings, and Taiwan Semiconductor posts strong quarterly sales.", url: "https://finnhub.io/api/news?id=aa78361f5e07292fb6dd0b671afdf0179c5becd8eb0b46810d34d5270ec72c26"),
        NewsItemData(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks and More : Nvidia, Delta, Taiwan Semiconductor, PriceSmart, WD-40, and More", source: "Yahoo", datetime: "April 10, 2024", summary: "Nvidia stock slips after shares enter a correction, Delta is scheduled to report.", url: "https://finnhub.io/api/news?id=aa78361f5e07292fb6dd0b671afdf0179c5becd8eb0b46810d34d5270ec72c26"),
        NewsItemData(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks Are Moving the Most Today", source: "Yahoo", datetime: "April 10, 2024", summary: "first-quarter earnings, and Taiwan Semiconductor posts strong quarterly sales", url: "https://finnhub.io/api/news?id=aa78361f5e07292fb6dd0b671afdf0179c5becd8eb0b46810d34d5270ec72c26"),
        
    ]))
}
