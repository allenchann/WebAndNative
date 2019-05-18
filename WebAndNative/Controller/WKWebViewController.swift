//
//  WKWebViewController.swift
//  WebAndNative
//
//  Created by CWL on 2019/5/7.
//  Copyright © 2019 sino. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController {
    
    @IBOutlet weak var callJS: UIBarButtonItem!
    var wkWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加wkwebview.如果要向下兼容的话，无法在sb文件中添加wkwebview。需要手动添加
        self.initWebView()
        
    }
    //初始化webview
    func initWebView() {
        self.wkWebView = WKWebView(frame: self.view.bounds, configuration: self.setWebConfigure())
        self.wkWebView.navigationDelegate = self
        self.wkWebView.uiDelegate = self
        self.view.addSubview(self.wkWebView)
        let url = Bundle.main.url(forResource: "index", withExtension: "html")
        let request = URLRequest(url: url!)
        wkWebView.load(request)
    }
    //生成webconfiguration
    func setWebConfigure() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        //在此处注册方法，js发送消息后，才可以掉调用原生方法
        //js发送消息为：window.webkit.messageHandlers.callNative.postMessage
        config.userContentController.add(self, name: "callNative")
        return config
    }
    //native调用js中的方法
    @IBAction func callJS(_ sender: Any) {
        wkWebView.evaluateJavaScript("nativeCall()") { (obj, error) in
            print(error?.localizedDescription ?? "")
        }
    }
    //js调用原生的响应方法
    func callNative() {
        print("被调用了")
    }

    
}

// MARK:-
// MARK:webview加载代理
extension WKWebViewController:WKNavigationDelegate {
    //webview加载成功后，右上角的调用按钮才可以点击
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.callJS.isEnabled = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url;
        if url?.host == "callNative" {
            self.callNative()
            decisionHandler(.cancel)
            return;
        }
        decisionHandler(.allow)
    }
}

// MARK:-
// MARK:webviewUI代理
extension WKWebViewController:WKUIDelegate {
    //使用WkWebview时发现无法alert，原因是wkwebview拦截了该响应，需要在代理回调中手动弹出alert，
    //注意此处需要返回completionHandler,不然程序会crash
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK:-
// MARK:webview接收回调代理
extension WKWebViewController:WKScriptMessageHandler {
    //js发起message时会响应该代理，我们就是在该代理方法中完成原生与js的交互
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //判断message的名称，确定调用哪一个方法
        if message.name.isEqual("callNative")  {
            self.callNative()
        }
    }
    
}
