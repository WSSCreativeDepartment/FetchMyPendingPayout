//
//  bittrexCallWidget.swift
//  Steemple widget
//
//  Created by Mario Kardum on 03/07/2018.
//  Copyright © 2018 dumar022. All rights reserved.
//

import Foundation
struct steemInfo {
    
    // This is what I learned from YouTube in tutorial for create a weather app
    let marketName:String
    let last:Double
    
    
    // Handling the errors
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String,Any)
    }
    
    
    
    init(json:[String:Any]) throws {
        guard let marketName = json["MarketName"] as? String else {throw SerializationError.missing("MarketName is missing")}
        guard let last = json["Last"] as? Double else { throw SerializationError.missing("Last price is missing")}
        
        self.marketName = marketName
        self.last = last
        
    }
    
    // Bittrex API data - the same as in bittrexCall file
    // base path is the first part of the URL, the second can be found in TodayViewContrller
    
    static let basePath = "https://bittrex.com/api/v1.1/public/getmarketsummary?market="
    static func forecast (withMarket Market:String, completion: @escaping ([steemInfo]) -> ()) {
        
        let url = basePath + Market
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            var forecastArray:[steemInfo] = []
            
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
