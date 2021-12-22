//
//  CoinRainData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import Foundation


class CoinData:Codable{
    
    class CoinSupply:Codable{
        var confirmed:Bool?
        var total:String?
        var circulating:String?
    }
    
    class CoinLink:Codable{
        var name:String?
        var type:String?
        var url:String?
    }
    
    class CoinAllTimeHigh:Codable{
        var price:String?
        var timestamp:Double
    }

    var uuid:String?
    var symbol:String?
    var name:String?
    var description:String?
    var color:String?
    var iconUrl:String?
    var websiteUrl:String?
    var supply:CoinSupply?
    var links:[CoinLink?]?
    var _24hVolume:String?
    var allTimeHigh:CoinAllTimeHigh?
    var numberOfMarkets:Int?
    var numberOfExchanges:Int?
    var marketCap:String?
    var price:String?
    var tier:Int?
    var change:String?
    var rank:Int?
    var sparkline:[String?]?
    var lowVolume:Bool?
    var coinrankingUrl:String?
    var btcPrice:String?
    
    var WebsiteUrl:String{
        return self.websiteUrl ?? ""
    }
    
    var Supply:CoinSupply{
        return self.supply ?? .init()
    }
    
    var Links:[CoinLink]{
        return self.links?.compactMap({$0}) ?? []
    }
    
    var Description:String{
        return self.description ?? ""
    }
    
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
        var coin:CoinData?
    }
    
    var data:InnerCoinsData?
}
