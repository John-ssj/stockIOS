//
//  HomeView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/3/24.
//

import SwiftUI
import Alamofire

struct HomeView: View {
    @ObservedObject var data: ViewModel
    
    var body: some View {
        NavigationView {
            List {
                Text(getFormatDate())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                    .padding(.vertical, 5)
                
                Section(header: Text("PORTFOLIO")) {
                    PortfolioInfoView(data: data.protfolioInfo)
                    ForEach(data.protfolioList, id: \.self) { d in
                        PortfolioItemView(data: d)
                    }
                    .onMove(perform: movePortfolioItems)
                }
                
                Section(header: Text("FAVORITES")) {
                    ForEach(data.favoriteList, id: \.self) { d in
                        FavoriteItemView(data: d)
                    }
                    .onDelete(perform: deleteFavoriteItems)
                    .onMove(perform: moveFavoriteItems)
                }
                
                HStack{
                    Spacer()
                    Link("Powered by Finnhub.io", destination: URL(string: "https://finnhub.io")!)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.gray)
                    Spacer()
                }
            }
            .navigationTitle("Stocks")
            .toolbar {
                EditButton()
            }
        }
    }
}

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var protfolioInfo = PortfolioInfoView.ViewModel(worth: 25000, balance: 25000)
        @Published var protfolioList: [PortfolioItemView.ViewModel] = []
        @Published var favoriteList: [FavoriteItemView.ViewModel] = []
        
        static let model = {
            let m = ViewModel()
            m.getDataFromServer()
            return m
        }()
        
        private init() {}
        
        func getDataFromServer() {
            AF.request(serverUrl + "/financial/getAll").responseDecodable(of: FinancialData.self) { response in
                switch response.result {
                case .success(let financialData):
                    self.protfolioInfo.balance = financialData.wallet
                    self.protfolioList = financialData.portfolio
                        .sorted(by: { l, r in
                            l.index > r.index
                        }).map({ d in
                            print(d.index, d.stock)
                            return PortfolioItemView.ViewModel(d: d)
                        })
                    self.favoriteList = financialData.watchList
                        .sorted(by: { l, r in
                            l.index > r.index
                        }).map({ d in
                            FavoriteItemView.ViewModel(d: d)
                        })
                    self.protfolioInfo.worth = self.caculateWorth()
                case .failure(let error):
                    print("Error while fetching data: \(error.localizedDescription)")
                }
            }
        }
        
        private func caculateWorth() -> Double {
            var worth = self.protfolioInfo.balance
            _ = protfolioList.map { p in
                worth += p.marketValue
            }
            return worth
        }
    }
}

extension HomeView {
    func getFormatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d,yyyy"
        return formatter.string(from: Date())
    }
    
    func movePortfolioItems(from source: IndexSet, to destination: Int) {
        data.protfolioList.move(fromOffsets: source, toOffset: destination)
        let param: [String] = data.protfolioList.map { p in
            p.stock
        }.reversed()
        print(param)
        AF.request(serverUrl + "/financial/sortPortfolio", method: .post, parameters: ["sort": param], encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                return
                            }
                        }
                    } catch { }
                }
                ViewModel.model.getDataFromServer()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func deleteFavoriteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.compactMap { data.favoriteList[$0] }
        if(itemsToDelete.count > 1) { return }
        let stock = itemsToDelete[0].stock
        print("index: ", offsets, " ,", stock)
        
        data.favoriteList.remove(atOffsets: offsets)
        AF.request(serverUrl + "/financial/removeWatchList?symbol=" + stock).response{ response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                return
                            }
                        }
                    } catch { }
                }
                ViewModel.model.getDataFromServer()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func moveFavoriteItems(from source: IndexSet, to destination: Int) {
        data.favoriteList.move(fromOffsets: source, toOffset: destination)
        let param: [String] = data.favoriteList.map { p in
            p.stock
        }.reversed()
        AF.request(serverUrl + "/financial/sortWatchList", method: .post, parameters: ["sort": param], encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                return
                            }
                        }
                    } catch { }
                }
                ViewModel.model.getDataFromServer()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    HomeView(data: HomeView.ViewModel.model)
}
