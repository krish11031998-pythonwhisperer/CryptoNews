//
//  CoinRainData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import Foundation


class CoinData:Codable{
    
    var uuid:String?
    var symbols:String?
    var name:String?
    var color:String?
    var iconUrl:String?
    var marketCap:String?
    var price:String?
    var tier:Int?
    var change:String?
    var rank:Int?
    var sparkline:[String]?
    var lowVolume:Bool?
    var coinrankingUrl:String?
    var btcPrice:String?
}

class CoinsData:Codable{
    
    class InnerCoinsData:Codable{
        var coins:[CoinData]?
    }
    
    var data:InnerCoinsData?
}
