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
    
    
    // Bittrex Market info labels
    
    @IBOutlet weak var market1: UILabel!
    @IBOutlet weak var market2: UILabel!
    @IBOutlet weak var market3: UILabel!
    
    @IBOutlet weak var price1: UILabel!
    @IBOutlet weak var price2: UILabel!
    @IBOutlet weak var price3: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
      
     
        
        if let name = UserDefaults.init(suiteName: "group.steempleGroup")?.value(forKey: "MyNameIs"){
            
         //   Fetching username from ViewController. It remains saved in the app when it is turned off or when it works in the background, untill you change it
            
            author.text = name as? String
            
        }
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            //expanded
            self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
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
        bittrex()

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
                    // Calling the author
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
    
    // Checkin the internal market
    
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
    
    //calling the Bittrex info from bittrexCallWidget
    
    
    func bittrex() {
        steemInfo.forecast(withMarket: "btc-steem") { (results:[steemInfo]) in
            for marketName in results {
                self.market1.text = marketName.marketName
                let c:String = String(format: "%f", marketName.last)
                self.price1.text = c
                
            }
        }
        
        steemInfo.forecast(withMarket: "btc-sbd") { (results:[steemInfo]) in
            for marketName in results {
                self.market2.text = marketName.marketName
                let d:String = String(format: "%f", marketName.last)
                self.price2.text = d
                
            }
            
        }
        
        steemInfo.forecast(withMarket: "usd-btc") { (results:[steemInfo]) in
            for marketName in results {
                self.market3.text = marketName.marketName
                let e:String = String(format: "%f", marketName.last)
                self.price3.text = e
                
            }
            
        }
    }
   
}
