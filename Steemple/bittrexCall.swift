//
//  bittrexCall.swift
//  Steemple
//
//  Created by Mario Kardum on 03/07/2018.
//  Copyright © 2018 dumar022. All rights reserved.
//

import Foundation
struct steemInfo {
    
    // I learned this method on YouTube, in a tutorial of building a weather app
    // marketName is a String because of "" last is Double
    
    let marketName:String
    let last:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String,Any)
    }
    
    // Handling some possible errors
    
    init(json:[String:Any]) throws {
        guard let marketName = json["MarketName"] as? String else {throw SerializationError.missing("MarketName is missing")}
        guard let last = json["Last"] as? Double else { throw SerializationError.missing("Last price is missing")}
        
        self.marketName = marketName
        self.last = last
        
    }
    
    // BasePath is only half of URL, other part is defined in ViewController
    
    static let basePath = "https://bittrex.com/api/v1.1/public/getmarketsummary?market="
    static func forecast (withMarket Market:String, completion: @escaping ([steemInfo]) -> ()) {
        
        
        
        let url = basePath + Market
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            var forecastArray:[steemInfo] = []
            
            
            // Bittrex API for things I need is nesting. Now I will call "results"
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        
                        if let results = json["result"] as? [[String:Any]]{
                            for dataPoint in results {
                                if let marketObject = try? steemInfo(json: dataPoint) {
                                    forecastArray.append(marketObject)
                                }
                            }
                        }
                        
                    }
                } catch {
                    print(error.localizedDescription)
                    
                }
                
                completion(forecastArray)
            }
        }
        
        task.resume()
    }
}
