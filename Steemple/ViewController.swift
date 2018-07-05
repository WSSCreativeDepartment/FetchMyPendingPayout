//
//  ViewController.swift
//  Steemple
//
//  Created by Mario Kardum on 17/06/2018.
//  Copyright © 2018 dumar022. All rights reserved.
//

import UIKit
import SwiftyJSON
import Steemple_framework

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    
    @IBOutlet weak var typeUserName: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pendingPayoutLabel: UILabel!
    

  
    
    @IBOutlet weak var steemPrice: UILabel!
    
    // Outlets for Bittrex Market Info
    
    @IBOutlet weak var arketOne: UILabel!
    @IBOutlet weak var marketTwo: UILabel!
    @IBOutlet weak var marketThree: UILabel!
    
    @IBOutlet weak var priceOne: UILabel!
    @IBOutlet weak var priceTwo: UILabel!
    @IBOutlet weak var priceThree: UILabel!
    
    // permLabel is here for nothing, I plan to use it in the future
    
    var permLabel: UILabel?
    
    
    @IBOutlet weak var votesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // This is other part of Bittrex API url
        
        
        
        // Let's start with btc-steem market
        // marketName is a string, while "last" is Double so we have to convert it to String using parameter "c"
        
        steemInfo.forecast(withMarket: "btc-steem") { (results:[steemInfo]) in
            for marketName in results {
                self.arketOne.text = marketName.marketName
                let c:String = String(format: "%f", marketName.last)
                self.priceOne.text = c
                
            }
        }
        
        
        // btc-sbd market
            
            steemInfo.forecast(withMarket: "btc-sbd") { (results:[steemInfo]) in
                for marketName in results {
                    self.marketTwo.text = marketName.marketName
                    let d:String = String(format: "%f", marketName.last)
                    self.priceTwo.text = d
                    
                }
            
        }
        
        // usd-btc market.. i will use it to count usd-steem and usd-sbd market
        
        steemInfo.forecast(withMarket: "usd-btc") { (results:[steemInfo]) in
            for marketName in results {
                self.marketThree.text = marketName.marketName
                let e:String = String(format: "%f", marketName.last)
                self.priceThree.text = e
                
            }
            
        }
        
        
        
        
        // If there is a saved username already there, let's use it
        
        
        // First, let's get some rouded corners
        typeUserName.layer.cornerRadius = 8
       
        
        
        
        
        
        self.typeUserName.delegate = self
        
        
        if let x = UserDefaults.standard.object(forKey: "MyUsername") as? String {
            typeUserName.text = x
        }
        
        // Since Steemit has Resteem option, user and author don't have to be the same person
        
        userLabel.text = typeUserName.text
        if userLabel.text != nil {
            
            // Calling the main function
            ticker()
           SteemApi()
            

        }
            
            
        else {
            return
        }
        
        
        
    }
    
    
    // The warning message
    
  
    
    // Hide keyboard and textfield functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // This function allows only lowercase and no whitespace
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //just change this charectar username  it's a text field
        if textFieldToChange == typeUserName {
            let characterSetNotAllowed = CharacterSet.whitespaces
            if let _ = string.rangeOfCharacter(from:NSCharacterSet.uppercaseLetters) {
                return false
            }
            if let _ = string.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive) {
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        typeUserName.resignFirstResponder()
        
 
        UserDefaults.standard.set(typeUserName.text, forKey: "MyUsername")
        UserDefaults.init(suiteName: "group.steempleGroup")?.set(self.typeUserName.text, forKey: "MyNameIs")
        
        
        userLabel.text = typeUserName.text
        
        // Calling the main function
        
      SteemApi()
        
        

        
        return true
    }
    
    
    // Main function
    
    func SteemApi() {
        
        
        // url SteemJS api (Content by blog), instead of username, the function adds the text from userLabel
        let url = URL(string: "https://api.steemjs.com/get_discussions_by_blog?query=%7B%22tag%22%3A%22" + userLabel.text! + "%22%2C%20%22limit%22%3A%20%221%22%7D")
        
        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: AnyObject]]
                    
                    
                    //Let's call pending payout
                    if let payout = json[0]["pending_payout_value"] {
                        DispatchQueue.main.async {
                            self.pendingPayoutLabel.text = payout as? String
                        }
                    }
                    
                    // Let's call the title of the post
                    if let title = json[0]["title"] {
                        DispatchQueue.main.async {
                            self.titleLabel.text = title as? String
                        }
                    }
                    
               
                    // Let's call the username of the author
                    if let theAuthor = json[0]["author"] {
                        DispatchQueue.main.async {
                            self.authorLabel.text = theAuthor as? String
                        }
                    }
                    
                    // Let's call the username of the author
                    if let thePermlink = json[0]["permlink"] {
                        DispatchQueue.main.async {
                            self.permLabel?.text = thePermlink as? String
                            
                        }
                        
                    }
                    
               
                    
  
          
                 
                    
                }catch let error as NSError{
                    print(error)
                }
            }
            
        

           
            
        }).resume()
        
        
        
        
    }

    // The function for internal market in Steem Blockchain
    
    //
    
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
    


    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


