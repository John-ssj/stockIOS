//
//  stocksAppApp.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/3/24.
//

import SwiftUI

@main
struct stocksAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(data: HomeView.ViewModel.model)
        }
    }
}

let serverUrl = "https://web4-ios.wl.r.appspot.com"
