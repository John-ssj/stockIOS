//
//  NewsDetailView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/11/24.
//

import SwiftUI

struct NewsDetailView: View {
    @Binding var selectedNews: NewsItemData?
    @ObservedObject var data: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Spacer()
                
                Button {
                    selectedNews = nil
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.black)
                }

            }
            
            Text(data.source)
                .font(.title)
                .fontWeight(.bold)
            
            Text(data.datetime)
                .fontWeight(.medium)
                .font(.footnote)
                .foregroundColor(Color.gray)
            
            Divider()
                .padding(.vertical, 10)
            
            Text(data.headline)
                .font(.callout)
                .fontWeight(.semibold)
            
            Text(data.summary)
                .font(.footnote)
                .fontWeight(.regular)
                .lineLimit(20)
            
            HStack {
                Text("For more details click")
                    .foregroundColor(Color.gray)
                
                Link("here", destination: URL(string: data.url)!)
            }
            .font(.footnote)
            .fontWeight(.medium)
            
            HStack(spacing: 10) {
                Link(destination: URL(string: data.twitterShareUrl)!) {
                    Image("x")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Link(destination: URL(string: data.facebookShareUrl)!) {
                    Image("facebook")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.vertical, 10)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}
extension NewsDetailView {
    class ViewModel: ObservableObject {
        @Published var imgUrl: String = ""
        @Published var headline: String = ""
        @Published var source: String = ""
        @Published var datetime: String = ""
        @Published var summary: String = ""
        @Published var url: String = ""
        @Published var twitterShareUrl: String = ""
        @Published var facebookShareUrl: String = ""
        
        init(imgUrl: String, headline: String, source: String, datetime: String, summary: String, url: String) {
            self.imgUrl = imgUrl
            self.headline = headline
            self.source = source
            self.datetime = datetime
            self.summary = summary
            self.url = url
            self.twitterShareUrl = "https://twitter.com/intent/tweet?text=\(encodeURIComponent(headline))&url=\(encodeURIComponent(url))"
            self.facebookShareUrl = "https://www.facebook.com/sharer/sharer.php?u=\(encodeURIComponent(url))&amp;src=sdkpreparse"
        }
        
        init(d: NewsItemData) {
            self.imgUrl = d.imgUrl
            self.headline = d.headline
            self.source = d.source
            self.datetime = d.datetime
            self.summary = d.summary
            self.url = d.url
            self.twitterShareUrl = "https://twitter.com/intent/tweet?text=\(encodeURIComponent(headline))&url=\(encodeURIComponent(url))"
            self.facebookShareUrl = "https://www.facebook.com/sharer/sharer.php?u=\(encodeURIComponent(url))&amp;src=sdkpreparse"
        }
        
        func encodeURIComponent(_ text: String) -> String {
            return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        }
    }
}

#Preview {
    NewsDetailView(selectedNews: .constant(nil), data: NewsDetailView.ViewModel(imgUrl: "https://s.yimg.com/ny/api/res/1.2/euQSw3.dSpyGJdVN5H_ZIw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02MDA-/https://media.zenfs.com/en/Barrons.com/c9ed8009b3d8d858b29ad4bf0c110f86", headline: "These Stocks Are Moving the Most Today: Nvidia, Delta, Taiwan Semiconductor, PriceSmart, WD-40, and More", source: "Yahoo", datetime: "April 10, 2024", summary: "Nvidia stock slips after shares enter a correction, Delta is scheduled to report first-quarter earnings, and Taiwan Semiconductor posts strong quarterly sales.", url: "https://finnhub.io/api/news?id=aa78361f5e07292fb6dd0b671afdf0179c5becd8eb0b46810d34d5270ec72c26"))
}
