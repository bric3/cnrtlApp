//
//  dictVC.swift
//  cnrtlApp
//
//  Created by Black_Shark on 4/9/15.
//  Copyright (c) 2015 Black_Shark. All rights reserved.
//

import UIKit

class dictVC: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var appsWebView: UIWebView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var frameSearchView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        appsWebView.frame = CGRectMake(0, 0, theWidth, theHeight*8/10)
        frameSearchView.frame = CGRectMake(0, theHeight*8/10, theWidth, theHeight*2/10)
        searchTextView.frame = CGRectMake(0, 0, theWidth-52, theHeight*2/10)
        searchBtn.center = CGPointMake(self.frameSearchView.frame.size.width - 50, 24)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchCNRTL(searchTerm: String) {
        // TODO does not look up new words after looking up first word. 
        // TODO get rid of all extra html
        println("searching for \(searchTerm)")
        // Now escape anything else that isn't URL-friendly
        if let cnrtlSearchTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://cnrtl.fr/definition/\(cnrtlSearchTerm)"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                let html = NSURLRequest(URL: url!)
                self.appsWebView!.loadRequest(html)
            })
            
            task.resume()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.appsWebView!.reload()
    }
    
    @IBAction func searchBtn_click(sender: AnyObject) {
        if searchTextView.text != "" {
            searchCNRTL(searchTextView.text)
            searchTextView.text = ""
        }
    }


}
