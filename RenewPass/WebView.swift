//
//  WebView.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-07.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit

class WebView: UIWebView
{
    var uiView = UIView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.delegate = self
    }
    
    convenience init(frame:CGRect, request:URLRequest)
    {
        self.init(frame: frame)
        uiView.addSubview(self)
        loadRequest(request)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WebView: UIWebViewDelegate
{
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        //print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        //print("webViewDidFinishLoad")
        NotificationCenter.default.post(name: Notification.Name("webViewDidFinishLoad"), object: nil)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        //print("An error occurred while loading the webview")
        NotificationCenter.default.post(name: Notification.Name("webViewDidFailLoadWithError"), object: nil)
        print(error)
    }
}
