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
    
    @IBOutlet weak var mesageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageOK: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If there is a saved username already there, let's use it
        typeUserName.layer.cornerRadius = 8
        messageOK.layer.cornerRadius = 23
        mesageView.layer.cornerRadius = 12
        
       typeUserName.isHidden = true
        
        self.typeUserName.delegate = self
        
        
        if let x = UserDefaults.standard.object(forKey: "MyUsername") as? String {
            typeUserName.text = x
        }
        
        // Since Steemit has Resteem option, user and author don't have to be the same person
        
        userLabel.text = typeUserName.text
        if userLabel.text != nil {
            
            // Calling the main function
           SteemApi()
            
        }
            
        else {
            return
        }
    }
    
    // Hide keyboard and textfield functions
    
    
    @IBAction func messageOKAction(_ sender: Any) {
        messageLabel.isHidden = true
        mesageView.isHidden = true
        messageOK.isHidden = true
        typeUserName.isHidden = false
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
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

