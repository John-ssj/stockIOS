//
//  NewsItemView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI
import Kingfisher

struct NewsItemView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(data.source)
                        .fontWeight(.bold)
                    
                    Text(data.dateString)
                        .fontWeight(.medium)
                }
                .font(.footnote)
                .foregroundColor(Color.gray)
                
                Text(data.headline)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
            
            Spacer()
            
            KFImage(URL(string: data.imgUrl))
                .cancelOnDisappear(true)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(20)
        }
    }
}

extension NewsItemView {
    class ViewModel: ObservableObject {
        @Published var imgUrl: String = ""
        @Published var headline: String = ""
        @Published var source: String = ""
        @Published var dateString: String = ""
        
        init(imgUrl: String, headline: String, source: String, dateString: String) {
            self.imgUrl = imgUrl
            self.headline = headline
            self.source = source
            self.dateString = dateString
        }
        
        init(d: NewsItemData) {
            self.imgUrl = d.imgUrl
            self.headline = d.headline
            self.source = d.source
            self.dateString = DateFromNow(t: d.datetime)
        }
    }
}

#Preview {
    NewsItemView(data: NewsItemView.ViewModel(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks Are Moving the Most Today: Nvidia, Delta, Taiwan Semiconductor, PriceSmart, WD-40, and More", source: "Yahoo", dateString: "10 hr, 10min"))
}
