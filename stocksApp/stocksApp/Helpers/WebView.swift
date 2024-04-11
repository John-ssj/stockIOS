//
//  WebView.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var htmlFilename: String
    var data: String
    
    func makeUIView(context: Context) -> WKWebView {
        let conf = WKWebViewConfiguration()
        let jsString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'device-width=width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUserScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        conf.userContentController = WKUserContentController()
        conf.userContentController.addUserScript(wkUserScript)
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350), configuration: conf)
        
        webView.navigationDelegate = context.coordinator
        
        if let filepath = Bundle.main.path(forResource: htmlFilename, ofType: "html") {
            do {
                let contents = try String(contentsOfFile: filepath)
                webView.loadHTMLString(contents, baseURL: nil)
            } catch {
                print("Cannot load file")
            }
        } else {
            print("HTML file not found")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, data: data)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var data: String
        
        init(_ parent: WebView, data: String) {
            self.parent = parent
            self.data = data
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("loadCharts(\(data));") { result, error in
                if let error = error {
                    print("Error calling javascript:loadCharts()")
                    print(error.localizedDescription)
                }
            }
        }
    }
}
