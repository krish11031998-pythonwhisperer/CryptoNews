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
    var tracked:[CrybseAssetCoin]?
    var watching:[CrybseAssetCoin]?
    
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

class CrybseAssetCoin:Codable{
    var currency:String?
    var coinData:CrybseCoin?
    var value:Float?
}

class CrybseCoin: Codable{
    var uuid:String?
    var symbol:String?
    var name:String?
    var description:String?
    var color:String?
    var iconUrl:String?
    var marketCap:Float?
    var price:Float?
    var tier:Int?
    var change:Float?
    var rank:Int?
    var sparkline:[Float]?
    var lowVolume:Bool?
    var coinrankingUrl:String?
    var btcPrice:Float?
    
    var Sparkline:[Float]{
        return self.sparkline ?? []
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
    
    
    var Change:Float{
        return self.change ?? 0.0
    }
    
    
}
