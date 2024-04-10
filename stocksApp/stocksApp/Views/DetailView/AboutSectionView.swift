//
//  AboutSectionView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct AboutSectionView: View {
    @ObservedObject var data: ViewModel
    
    init(data: ViewModel?) {
        self.data = data ?? ViewModel()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .font(.title)
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("IPO Start Date:")
                    Text("Industry:")
                    Text("Webpage:")
                    Text("Company Peers:")
                }
                .fontWeight(.heavy)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(data.startTime)
                        .lineLimit(1)
                    Text(data.industry)
                        .lineLimit(1)
                    Link(destination: URL(string: data.weburl)!) {
                        Text(data.weburl)
                            .lineLimit(1)
                    }
                    if(data.peers.isEmpty) {
                        Text("")
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(data.peers, id: \.self) { p in
                                    NavigationLink(destination: DetailView(stock: p)) {
                                        Text(p + ",")
                                            .lineLimit(1)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .frame(width: 180)
                    }
                }
                .fontWeight(.medium)
            }
            .font(.footnote)
        }
    }
}

extension AboutSectionView {
    class ViewModel: ObservableObject {
        @Published var startTime: String = "1970-00-00"
        @Published var industry: String = ""
        @Published var weburl: String = ""
        @Published var peers: [String] = []
        
        init() {}
        
        init(startTime: String, industry: String, weburl: String, peers: [String]) {
            self.startTime = startTime
            self.industry = industry
            self.weburl = weburl
            self.peers = peers
        }
        
        init(d: AboutData) {
            self.startTime = d.ipo
            self.industry = d.industry
            self.weburl = d.webpage
            self.peers = d.peers
        }
    }
}

#Preview {
    AboutSectionView(data: AboutSectionView.ViewModel(startTime: "1980-12-12", industry: "Technology", weburl: "https://www.apple.com/", peers: ["AAPL", "DELL", "SMCI", "HPQ", "HPE"]))
}
