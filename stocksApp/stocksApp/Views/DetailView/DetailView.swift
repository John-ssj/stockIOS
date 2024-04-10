//
//  DetailView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/9/24.
//

import SwiftUI
import Alamofire

struct DetailView: View {
    @State var stock: String
    @ObservedObject var data: ViewModel = ViewModel()
    @State var showToast = false
    @State var toastMessage = "test Toast"
    
    var body: some View {
        if(!data.loadDate) {
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Fetching Data...")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
        } else {
            VStack{
                Text(stock)
            }
            .navigationTitle(stock)
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
        @Published var loadDate = true
        @Published var favorite = false
    }
}

extension DetailView {
    func AddRemoveFavorite() {
        let addRemoveFavoriteUrl = serverUrl + "/financial/" + (data.favorite ? "removeWatchList" : "addWatchList") + "?symbol=" + stock
        data.favorite.toggle()
        AF.request(addRemoveFavoriteUrl).response{ response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                self.showToast = true
                                self.toastMessage = data.favorite ? ("Adding " + stock + " to Favorites") : ("Removing " + stock + " from Favorites")
                                return
                            }
                        }
                    } catch { }
                }
                self.showToast = true
                self.toastMessage = data.favorite ? ("Failed to add " + stock + " to Favorites") : ("Failed to remove " + stock + " from Favorites")
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    DetailView(stock: "AAPL")
}
