//
//  CoinRainData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import Foundation


class CoinData:Codable{
    
    var uuid:String?
    var symbol:String?
    var name:String?
    var color:String?
    var iconUrl:String?
    var marketCap:String?
    var price:String?
    var tier:Int?
    var change:String?
    var rank:Int?
    var sparkline:[String?]?
    var lowVolume:Bool?
    var coinrankingUrl:String?
    var btcPrice:String?
    
    var Symbol:String{
        return self.symbol ?? "XXX"
    }
    
    var Name:String{
        return self.name ?? ""
    }
    
    var Color:String{
        return self.color ?? ""
    }
    
    var Price:Float{
        return self.price?.toFloat() ?? 0.0
    }
    
    var Sparkline:[Float]{
        return self.sparkline?.compactMap({$0 != nil ? $0!.toFloat() : nil}) ?? []
    }
    
    var Change:Float{
        return self.change?.toFloat() ?? 0.0
    }
    
}

class CoinsData:Codable{
    
    class InnerCoinsData:Codable{
        var coins:[CoinData]?
    }
    
    var data:InnerCoinsData?
}
