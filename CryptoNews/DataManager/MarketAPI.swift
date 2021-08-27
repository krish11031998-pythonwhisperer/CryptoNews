//
//  DataAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import Foundation
import Combine

struct AllMarketData:Codable{
    var data:Array<CoinMarketData>?
}

struct CoinMarketData:Codable{
    var id:Int?
    var s:String?
    var n:String?
    var p:Float?
    var p_btc:Float?
    var v:Float?
    var vt:Float?
    var pc:Float?
    var pch:Float?
    var mc:Float?
    var gs:Float?
    var ss:Float?
    var `as`:Float?
    var bl:Float?
    var br:Float?
    var sp:Float?
    var na:Int?
    var md:Int?
    var t:Float?
    var r:Float?
    var yt:Int?
    var u: Int? //URL Shares
    var c: Int? //Social Contributors (24 Hours)
    var sd:Float? //Social Dominance
    var d: Float? //Market Dominance
    var cr: Float?
    var acr: Int?
    var tc: Float?
    var timeSeries:Array<CoinMarketData>?
}

class MarketAPI:DAPI,ObservableObject{
    @Published var data:Array<CoinMarketData> = .init()
    var sort:String
    var limit:Int
    init(sort:String = "d",limit:Int = 10){
        self.sort = sort
        self.limit = limit
    }
    
    var marketURL:URL?{
        var uC = self.baseComponent
        uC.queryItems = [
            URLQueryItem(name: "data", value: "market"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
            URLQueryItem(name: "sort", value: self.sort),
            URLQueryItem(name: "desc", value: "true"),
            URLQueryItem(name: "limit", value: "\(self.limit)")
        ]
        return uC.url
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(AllMarketData.self, from: data)
            if let data = res.data{
                DispatchQueue.main.async {
                    self.data = data
                }
            }
            
        }catch{
            print("There was an error while : ",error.localizedDescription)
        }
    }
    
    func getMarketData(){
        self.getInfo(_url: self.marketURL, completion: self.parseData(data:))
    }
    
    
}
