//
//  CrybseCoinsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/12/2021.
//

import Foundation

class CrybseCoinsResponse: Codable{
    var data:CrybseAssets?
    var success:Bool
}


class CrybseAssets:Codable{
    var tracked:[CrybseAsset]?
    var watching:[CrybseAsset]?
    
    static func parseAssetsFromData(data:Data) -> CrybseAssets?{
        var coinData:CrybseAssets? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinsResponse.self, from: data)
            if let data = res.data, res.success{
                coinData = data
            }else{
                print("(DEBUG) Error while trying to get the CrybseCoinData : ")
            }
        }catch{
            print("(DEBUG) Error while trying to parse the CrybseCoinDataResponse : ",error.localizedDescription)
        }
        
        return coinData
    }
}

class CrybseAsset:tCodable{
    var currency:String?
    var txns:[Transaction]?
    var coinData:CrybseCoin?
    var value:Float?
    var profit:Float?
    var coinTotal:Float?
    var coin:CrybseCoinSocialData?
    
    var Currency : String {
        return self.currency ?? ""
    }
    
    var Txns:[Transaction]{
        return self.txns ?? []
    }
    
    var CoinData:CrybseCoin{
        return self.coinData ?? .init()
    }
    
    var Value:Float{
        return self.value ?? 0
    }
    
    var Profit:Float{
        return self.profit ?? 0
    }
    
    
}

class CrybseCoin: Codable{
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
    var _24hVolume:Float?
    var allTimeHigh:CoinAllTimeHigh?
    var numberOfMarkets:Int?
    var numberOfExchanges:Int?
    var marketCap:Float?
    var price:Float?
    var tier:Int?
    var change:Float?
    var rank:Int?
    var sparkline:[Float]?
    var lowVolume:Bool?
    var coinrankingUrl:String?
    var btcPrice:Float?
    
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
        return self.price ?? 0.0
    }
    
    var Sparkline:[Float]{
        return self.sparkline ?? []
    }
    
    var Change:Float{
        return self.change ?? 0.0
    }
    
    
}
