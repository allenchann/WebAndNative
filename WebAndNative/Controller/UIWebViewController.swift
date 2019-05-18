//
//  UIWebViewController.swift
//  WebAndNative
//
//  Created by CWL on 2019/5/7.
//  Copyright © 2019 sino. All rights reserved.
//

import UIKit
import JavaScriptCore


// MARK: 协议，定义js调取原生的方法列表
//千万千万千万要加@objc
@objc protocol CallNative:JSExport {
    func CallNative()
}

// MARK:-
class UIWebViewController: UIViewController {

    @IBOutlet weak var uiWebView: UIWebView!
    @IBOutlet weak var callJSBtn: UIBarButtonItem!
    
    var context:JSContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载本地html
        self.uiWebView.delegate = self
        let url = Bundle.main.url(forResource: "index", withExtension: "html")
        let request = URLRequest(url: url!)
        self.uiWebView.loadRequest(request)
    }
    
    //调用js中的方法
    @IBAction func callJS(_ sender: Any) {
        self.context?.evaluateScript("nativeCall()")
    }
    
}

// MARK: -
// MARK: webview代理
extension UIWebViewController:UIWebViewDelegate {
    //webview加载完成
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.callJSBtn.isEnabled = true
        //获取当前js context
        let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        //webview加载完成后，设置当前viewcontroller为Html中的app对象
        context.setObject(self, forKeyedSubscript: "app" as NSCopying & NSObjectProtocol)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //按照定制的请求规则，判断是否调用原生方法的
        if request.url?.host == "callNative" {
            self.CallNative()
            return false
        }
        return true
    }
}


// MARK: -
// MARK: 完成协议中定义的方法，js调用原生会默认调用此扩展中的方法
extension UIWebViewController:CallNative {
    func CallNative() {
        print("展示信息：")
    }
}
