//
//  LoginController.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UIWebViewDelegate {
    
    
    let appID = "6135700"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithVkClick(_ sender: UIButton) {
        VK.logout()
        let authWebView = UIWebView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height - 20))
        
        authWebView.tag = 1024;
        authWebView.delegate = self
        
        self.view.addSubview(authWebView)
        if let url = URL(string: "http://oauth.vk.com/authorize?client_id=\(self.appID)&scope=wall,friends,offline,messages,photos&redirect_uri=oauth.vk.com/blank.html&display=touch&response_type=token") {
            authWebView.loadRequest(URLRequest(url: url))
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    
    func closeAuthView() {
        self.view.viewWithTag(1024)?.removeFromSuperview()
        self.view.viewWithTag(1025)?.removeFromSuperview()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let currentUrl = webView.request?.url?.absoluteString
        if let _ = currentUrl?.lowercased().range(of: "access_token") {
            if let data = currentUrl?.components(separatedBy: CharacterSet(charactersIn: "=&")) {
                VK.login(userId: data[5], accessToken: data[1], expires: data[3])
                self.closeAuthView()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            var close = true
            let whitelist = [
                "vk.com/authorize",
                "vk.com/login",
                "vk.com/join"
            ]
            
            for item in whitelist {
                if let _ = currentUrl?.lowercased().range(of: item) {
                    close = false
                }
            }
            
            if close {
                closeAuthView()
            }
        }
    }
    
    
}
