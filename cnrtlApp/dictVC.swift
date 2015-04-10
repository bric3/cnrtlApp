//
//  dictVC.swift
//  cnrtlApp
//
//  Created by Black_Shark on 4/9/15.
//  Copyright (c) 2015 Black_Shark. All rights reserved.
//

import UIKit

class dictVC: UIViewController, UIWebViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var appsWebView: UIWebView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var frameSearchView: UIView!

    var frameSearchViewOriginalY:CGFloat = 0
    var appsWebViewOriginalY:CGFloat = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        appsWebView.frame = CGRectMake(0, 0, theWidth, theHeight-35)
        frameSearchView.frame = CGRectMake(0, appsWebView.frame.maxY, theWidth, 50)
        searchTextView.frame = CGRectMake(2, 1, self.frameSearchView.frame.size.width-80, 30)
        searchTextView.backgroundColor = UIColor.lightGrayColor()
        searchBtn.center = CGPointMake(frameSearchView.frame.size.width - 40, 15)
        
        appsWebViewOriginalY = self.appsWebView.frame.origin.y
        frameSearchViewOriginalY = self.frameSearchView.frame.origin.y
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        tapScrollViewGesture.numberOfTapsRequired = 1
        appsWebView.addGestureRecognizer(tapScrollViewGesture)
    }
    
    func didTapWebView() {
        self.view.endEditing(true)
    }
    
    func keyboardWasShown(notification:NSNotification) {
        let dict:NSDictionary = notification.userInfo!
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let rect:CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.appsWebView.frame.origin.y = self.appsWebViewOriginalY - rect.height
            self.frameSearchView.frame.origin.y = self.frameSearchViewOriginalY - rect.height
            }, completion: {
                (finished:Bool) in
        })
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let dict:NSDictionary = notification.userInfo!
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let rect:CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.appsWebView.frame.origin.y = self.appsWebViewOriginalY
            self.frameSearchView.frame.origin.y = self.frameSearchViewOriginalY
            }, completion: {
                (finished:Bool) in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchCNRTL(searchTerm: String) {
        println("searching for \(searchTerm)")
        // Now escape anything else that isn't URL-friendly
        if let cnrtlSearchTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://cnrtl.fr/definition/\(cnrtlSearchTerm)"
            let url = NSURL(string: urlPath)
            var error: NSError?
            // get only html relevant to definition of word
            let html = parseHTML(NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: &error)!)
            if let error = error {
                println("Error : \(error)")
            }
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                self.appsWebView!.loadHTMLString(html, baseURL: url!)
            })
            
            task.resume()
        }
    }
    
    func parseHTML(html: NSString) -> NSString {
        var err : NSError?
        var parser = HTMLParser(html: html, error: &err)
        if err != nil {
            println(err)
            exit(1)
        }
        
        var bodyNode = parser.body
        
        if let inputNodes = bodyNode?.findChildTags("div") {
            for node in inputNodes {
                if node.getAttributeNamed("id") == "contentbox" {
                    return node.rawContents
                }
            }
        }
        println("failed to find contentbox")
        return html
    }
    
    override func viewDidAppear(animated: Bool) {
        self.appsWebView!.reload()
    }
    
    @IBAction func searchBtn_click(sender: AnyObject) {
        if searchTextView.text != "" {
            searchCNRTL(searchTextView.text)
            searchTextView.text = ""
            self.view.endEditing(true)
        }
    }


}
