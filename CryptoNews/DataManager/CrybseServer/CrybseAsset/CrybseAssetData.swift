//
//  CrybseCoinsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/12/2021.
//

import Foundation
import SwiftUI

class CrybseAssetsResponse: Codable{
    var data:CrybseAssets?
    var success:Bool
}


class CrybseAssets:ObservableObject,Codable{
    @Published var assets:[String:CrybseAsset]?
    @Published var tracked:[String]?
    @Published var watching:[String]?

    var Tracked:[String]{
        get{
            return self.tracked ?? []
        }
        
        set{
            self.tracked = newValue
        }
    }
    
    var Watching:[String]{
        get{
            return self.watching ?? []
        }
        
        set{
            self.watching = newValue
        }
    }
    
    var trackedAssets:[CrybseAsset]{
        return self.tracked?.compactMap({self.assets?[$0] ?? nil}) ?? []
    }
    
    var watchingAssets:[CrybseAsset]{
        return self.watching?.compactMap({self.assets?[$0] ?? nil}) ?? []
    }
    
    enum CodingKeys:CodingKey{
        case assets
        case tracked
        case watching
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assets = try container.decode([String:CrybseAsset]?.self, forKey: .assets)
        tracked = try container.decode([String]?.self, forKey: .tracked)
        watching = try container.decode([String]?.self, forKey: .watching)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tracked, forKey: .tracked)
        try container.encode(watching, forKey: .watching)
    }
    
    static func parseAssetsFromData(data:Data) -> CrybseAssets?{
        var coinData:CrybseAssets? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseAssetsResponse.self, from: data)
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
    
    func updateAsset(sym:String,txn:Transaction){
        let asset = self.assets?[sym] ?? .init(currency: sym)
        asset.Txns.append(txn)
        asset.Value += txn.subtotal
        asset.CoinTotal += txn.asset_quantity
        if let price = asset.coinData?.Price{
            asset.Profit += Float((txn.asset_quantity * price - txn.subtotal)/txn.subtotal)/Float(asset.Txns.count)
        }
        self.assets?[sym] = asset
        if let _ = self.assets?[sym]{
            if !self.Tracked.contains(sym) && self.Watching.contains(sym){
                self.Watching.removeAll(where: {$0 == sym})
                self.Tracked.append(sym)
            }
        }else{
            self.Tracked.append(sym)
        }
    }
}

class CrybseAsset:ObservableObject,Codable{
    @Published var currency:String?
    @Published var txns:[Transaction]?
    @Published var coinData:CrybseCoin?
    @Published var value:Float?
    @Published var profit:Float?
    @Published var coinTotal:Float?
    @Published var coin:CrybseCoinSocialData?
    
    init(currency:String?){
        self.currency = currency
    }
    
    enum CodingKeys:CodingKey{
        case currency
        case txns
        case coinData
        case value
        case profit
        case coinTotal
        case coin
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Float?.self, forKey: .value)
        profit = try container.decode(Float?.self, forKey: .profit)
        coinTotal = try container.decode(Float?.self, forKey: .coinTotal)
        currency = try container.decode(String?.self, forKey: .currency)
        txns = try container.decode(Array<Transaction>?.self, forKey: .txns)
        coinData = try container.decode(CrybseCoin?.self, forKey: .coinData)
//        coin = try container.decode(CrybseCoinSocialData?.self, forKey: .coin)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(profit, forKey: .profit)
        try container.encode(coinTotal, forKey: .coinTotal)
        try container.encode(currency, forKey: .currency)
        try container.encode(txns, forKey: .txns)
        try container.encode(coinData, forKey: .coinData)
        try container.encode(coin, forKey: .coin)
    }
    
    var Currency : String {
        return self.currency ?? ""
    }
    
    var Txns:[Transaction]{
        get{
            return self.txns ?? []
        }
        
        set{
            self.txns = newValue
        }
    }
    
    var CoinData:CrybseCoin{
        return self.coinData ?? .init()
    }
    
    var Value:Float{
        get{
            return self.value ?? 0
        }
        
        set{
            self.value = newValue
        }
        
    }
    
    var Profit:Float{
        get{
            return self.profit ?? 0
        }
        
        set{
            self.profit = newValue
        }
    }
    
    var LatestPriceTime:Int{
        return self.coin?.TimeseriesData?.last?.time ?? 0
    }
    
    
    var CoinTotal:Float{
        get{
            return self.coinTotal ?? 0
        }
        
        set{
            self.coinTotal = newValue
        }
        
    }
    
    var Change:Float{
        return self.coinData?.Change ?? 0.0
    }
    
    var Rank:Int{
        return self.coinData?.rank ?? 0
    }
    
    var MarketCap:Float{
        return self.coinData?.marketCap ?? 0.0
    }
//    var Coin:CrybseCoinSocialData{
//        return self.coin ?? .init()
//    }
    
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
