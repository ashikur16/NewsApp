//
//  WKWebViewViewController.swift
//  NewsApp
//
//  Created by bjit on 15/1/23.
//

import UIKit
import WebKit

class WKWebViewViewController: UIViewController {
    
    var url: String?

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let url = url {
            let request = URLRequest(url: URL(string: url)!)
            self.webView.load(request)
                    
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
        if keyPath == "loading" {
            if webView.isLoading {
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        }
    }
}
