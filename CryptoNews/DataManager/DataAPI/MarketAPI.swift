//
//  DataAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import Foundation
import Combine
import SwiftUI

struct AllMarketData:Codable{
    var data:Array<CoinMarketData>?
}

enum Order:String{
    case desc = "desc"
    case incr = "incr"
}

struct CoinMarketData:Codable,Equatable{
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

class MarketAPI:DAPI{
    @Published var data:Array<CoinMarketData> = .init()
    var sort:String?
    var limit:Int
    var order:Order
    init(sort:String? = nil,limit:Int = 10,order:Order = .desc){
        self.sort = sort
        self.limit = limit
        self.order = order
    }
    
    var marketURL:URL?{
        var uC = self.baseComponent
        uC.queryItems?.append(contentsOf: [
            URLQueryItem(name: "data", value: "market"),
            URLQueryItem(name: "limit", value: "\(self.limit)")
        ])
        
        if let sort = self.sort{
            uC.queryItems?.append(URLQueryItem(name: "sort", value: sort))
        }
        
        if self.order == .desc{
            uC.queryItems?.append(URLQueryItem(name: "desc", value: "true"))
        }
        
        return uC.url
    }
    
    
    
    override func parseData(url:URL,data:Data){
//        DataCache.shared[url] = data
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(AllMarketData.self, from: data)
            if let data = res.data{
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.data = data
                    }
                }
            }
            
        }catch{
            print("There was an error while : ",error.localizedDescription)
        }
        DispatchQueue.main.async {
            self.loading = false
        }
    }
    
    func getMarketData(){
        self.getData(_url: self.marketURL)
    }
    
    
}
