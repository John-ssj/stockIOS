//
//  TradeView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/11/24.
//

import SwiftUI
import Alamofire

struct TradeView: View {
    @Binding var isTrading: Bool
    @State var stock: String
    @State var name: String
    
    @State private var sharesText: String = ""
    @State private var shares: Int = 0
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var tradeSuccess: Bool = false
    @State private var tradeMessage: String = ""
    @ObservedObject private var data: ViewModel = ViewModel()
    
    var body: some View {
        if(tradeSuccess) {
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                
                Text("Congratulations!")
                    .font(.title)
                    .foregroundColor(Color.white)
                
                Text(tradeMessage)
                    .font(.callout)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Button {
                    isTrading = false
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(Color.green)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 140)
                        .background(Capsule().fill(Color.white))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
        } else {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Spacer()
                    
                    Button {
                        isTrading = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.black)
                    }
                }
                
                Text("Trade " + name + " shares")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    TextField("0", text: $sharesText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 80, weight: .light))
                        .onChange(of: sharesText, { oldValue, newValue in
                            self.shares = Int(newValue) ?? 0
                        })
                    
                    Spacer()
                    
                    Text(shares > 1 ? "Shares" : "Share")
                        .font(.title)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Spacer()
                    Text("x $\(String(format:"%.2f", data.currentPrice))/share = $\(String(format:"%.2f", Double(shares) * data.currentPrice))")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text("$\(String(format:"%.2f", data.wallet)) available to buy \(stock)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                
                HStack(spacing: 20) {
                    Button {
                        buy()
                    } label: {
                        Text("Buy")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 70)
                            .background(Capsule().fill(Color.green))
                    }
                    
                    Button {
                        sell()
                    } label: {
                        Text("Sell")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 70)
                            .background(Capsule().fill(Color.green))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .onAppear(perform: {
                data.getDataFromServer(stock: stock)
            })
            .toast(isPresented: $showToast) {
                Text(toastMessage)
                    .foregroundColor(Color.white)
            }
        }
    }
}

extension TradeView {
    class ViewModel: ObservableObject {
        @Published var wallet: Double = 0
        @Published var currentPrice: Double = 0
        @Published var quantity: Int = 0
        
        func getDataFromServer(stock: String) {
            print("startgetData-TradeView: ", stock)
            AF.request(serverUrl + "/financial/getPrice?symbol=" + stock).responseDecodable(of: TradeData.self) { response in
                switch response.result {
                case .success(let tradeData):
                    self.wallet = tradeData.wallet
                    self.currentPrice = tradeData.currentPrice
                    self.quantity = tradeData.quantity
                case .failure(let error):
                    print("Error while fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension TradeView {
    func buy() {
        if(shares == 0) {
            toastMessage = "Please enter a valid amount"
            showToast = true
            return
        }
        if(shares < 1) {
            toastMessage = "Cannot buy non-positive shares"
            showToast = true
            return
        }
        if(Double(shares) * data.currentPrice > data.wallet) {
            toastMessage = "Not enough money to buy"
            showToast = true
            return
        }
        let buyUrl = "\(serverUrl)/financial/buy?symbol=\(stock)&quantity=\(shares)"
        AF.request(buyUrl).response { response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                tradeSuccess = true
                                let shareMessage = shares > 1 ? "shares" : "share"
                                tradeMessage = "You have successfully bought \(shares) \(shareMessage) of \(stock)"
                                return
                            }
                        }
                    } catch { }
                }
                print("err")
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func sell() {
        if(shares == 0) {
            toastMessage = "Please enter a valid amount"
            showToast = true
            return
        }
        if(shares < 1) {
            toastMessage = "Cannot sell non-positive shares"
            showToast = true
            return
        }
        if(shares > data.quantity) {
            toastMessage = "Not enough shares to sell"
            showToast = true
            return
        }
        let sellUrl = "\(serverUrl)/financial/sell?symbol=\(stock)&quantity=\(shares)"
        AF.request(sellUrl).response { response in
            switch response.result {
            case .success(let d):
                if let d = d, !d.isEmpty {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String: Bool] {
                            if let success = jsonObject["success"] , success {
                                tradeSuccess = true
                                let shareMessage = shares > 1 ? "shares" : "share"
                                tradeMessage = "You have successfully bought \(shares) \(shareMessage) of \(stock)"
                                return
                            }
                        }
                    } catch { }
                }
                print("err")
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    TradeView(isTrading: .constant(true), stock: "AAPL", name: "Apple Inc")
}
