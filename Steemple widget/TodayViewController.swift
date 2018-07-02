//
//  TodayViewController.swift
//  Steemple widget
//
//  Created by Mario Kardum on 17/06/2018.
//  Copyright © 2018 dumar022. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON
import Steemple_framework

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    // Outlets
    
        
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var payout: UILabel!
    
    @IBOutlet weak var userN: UILabel!
    @IBOutlet weak var steemPrice: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = UserDefaults.init(suiteName: "group.steempleGroup")?.value(forKey: "MyNameIs"){
            
         //   Fetching username from ViewController
            
            author.text = name as? String
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // This is function that refreshes the widget each time you visit it
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        
        completionHandler(NCUpdateResult.newData)
        SteemApi()
        ticker()

    }
    
    // The main function is the same as in ViewController
    func SteemApi() {
        let url = URL(string: "https://api.steemjs.com/get_discussions_by_blog?query=%7B%22tag%22%3A%22" + author.text! + "%22%2C%20%22limit%22%3A%20%221%22%7D")
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: AnyObject]]
                    
           // Calling the pending payout
                    if let payout = json[0]["pending_payout_value"] {
                        DispatchQueue.main.async {
                            self.payout.text = payout as? String
                        }
                    }
                    // Calling the pending payout
                    if let authors = json[0]["author"] {
                        DispatchQueue.main.async {
                            self.userN.text = authors as? String
                        }
                    }
                    
                    
                    
                    
                }catch let error as NSError{
                    print(error)
                }
            }
            
            
            
            
            
        }).resume()
        
    }
    
    func ticker() {
        let url = URL(string: "https://api.steemjs.com/get_ticker?=value")!
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    var json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    DispatchQueue.main.async {
                        self.steemPrice.text = json["latest"] as! String
                        
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
   
}
