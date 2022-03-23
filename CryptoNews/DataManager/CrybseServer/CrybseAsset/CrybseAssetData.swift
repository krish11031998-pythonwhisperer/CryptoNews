//
//  CrybseCoinsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/12/2021.
//

import Foundation
import SwiftUI
import Combine

class CrybseAssetsResponse: Codable{
    var data:CrybseAssets?
    var success:Bool
}


class CrybseAssets:ObservableObject,Codable{
    @Published var assets:[String:CrybseAsset]?
    @Published var tracked:[String]?
    @Published var watching:[String]?
    
    init(){}
    
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
    
    var ProfitValue:Float{
        var profit:Float = 0.0
        if let assetValues = self.assets?.values.compactMap({$0.Value}){
            profit = assetValues.reduce(0, {$0 + $1})
        }
        return profit
    }
    
    var Profit:Float{
        return self.ProfitValue/self.TotalCurrentValue
    }
    
    var InvestedValue:Float{
        return self.TotalCurrentValue - self.ProfitValue
    }
    
    var TotalCurrentValue:Float{
        var total:Float = 0.0
        if let assetsValues = self.assets?.values.compactMap({$0.Value}){
            total = assetsValues.reduce(0, {$0 + $1})
        }
        return total
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
    
    func updateAssetPrices(){
        let watching = self.Tracked + self.Watching
        CrybseMultiCoinPriceAPI.shared.getPrices(coins: watching) { prices in
            setWithAnimation {
                for (currency,price) in prices{
                    self.assets?[currency]?.Price = price.USD
                }
            }
        }
    }
}

class CrybseAsset:ObservableObject,Codable,Equatable{
    static func == (lhs: CrybseAsset, rhs: CrybseAsset) -> Bool {
        let currencyCondition = lhs.Currency == rhs.Currency
        let txnCondition = lhs.txns?.count == rhs.txns?.count
        let coinDataCondition = lhs.coinData?.Price == rhs.coinData?.Price
        let coinCondition = lhs.coin?.TimeseriesData.last?.time == rhs.coin?.TimeseriesData.last?.time
        
        return currencyCondition || txnCondition || coinCondition || coinDataCondition
    }
    
    @Published var currency:String?
    @Published var txns:[Transaction]?
    @Published var coinData:CrybseCoin?
    @Published var value:Float?
    @Published var profit:Float?
    @Published var coinTotal:Float?
    @Published var coin:CrybseCoinSocialData?
    
    var coinDataCancellable:AnyCancellable? = nil
    var coinSocialDataCancellable:AnyCancellable? = nil
    
    init(currency:String?){
        self.currency = currency
        self.coinDataCancellable = self.coinData?.objectWillChange.sink(receiveValue: { _ in
            setWithAnimation {
                self.objectWillChange.send()
            }
        })
        
        self.coinSocialDataCancellable = self.coin?.objectWillChange.sink(receiveValue: { _ in
            withAnimation(.easeInOut)  {
                self.objectWillChange.send()
            }
        })
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
    
    var Price:Float?{
        get{
            return self.coinData?.price
        }
        
        set{
            self.coinData?.price = newValue
        }
        
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
        return Int(self.coin?.TimeseriesData.last?.time ?? 0.0)
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
    
    var PriceData:Array<CryptoCoinOHLCVPoint>{
        get{
            return self.coin?.TimeseriesData ?? []
        }
        
        
        set{
            self.coin?.TimeSeriesData = newValue
        }
    }
    
    var Color:String{
        get{
            return self.coinData?.Color ?? "#FFFFFF"
        }
    }
    
    func updatePriceWithLatestTimeSeriesPrice(timeSeries:Array<CryptoCoinOHLCVPoint>?){
        guard let safeTimeseries = timeSeries, let latestPrice = safeTimeseries.last?.close else {return}
        let latestPrices = safeTimeseries.compactMap({$0.time != nil ? $0.Time >= self.LatestPriceTime + 60 ? $0 : nil : nil})
        setWithAnimation {
            self.coin?.TimeseriesData.append(contentsOf: latestPrices)
            self.updateAssetInfo(price: latestPrice)
        }
    }
    
    func updateAssetInfo(price latestClosePrice:Float) {
        let newValue = self.CoinTotal * latestClosePrice
        self.profit = self.Profit + (newValue - self.Value)
        self.value = newValue
        self.Price = latestClosePrice

    }
    
}
 

class CrybseCoin:ObservableObject,Codable{
    init(){}

   @Published var uuid:String?
   @Published var symbol:String?
   @Published var name:String?
   @Published var description:String?
   @Published var color:String?
   @Published var iconUrl:String?
   @Published var _24hVolume:Float?
   @Published var marketCap:Float?
   @Published var price:Float?
   @Published var tier:Int?
   @Published var change:Float?
   @Published var rank:Int?
   @Published var sparkline:[Float]?
   @Published var lowVolume:Bool?
   @Published var coinrankingUrl:String?
   @Published var btcPrice:Float?
    
    enum CodingKeys:CodingKey{
       case uuid
       case symbol
       case name
       case description
       case color
       case iconUrl
       case websiteUrl
       case supply
       case links
       case _24hVolume
       case allTimeHigh
       case numberOfMarkets
       case numberOfExchanges
       case marketCap
       case price
       case tier
       case change
       case rank
       case sparkline
       case lowVolume
       case coinrankingUrl
       case btcPrice
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String?.self, forKey: .uuid)
        symbol = try container.decode(String?.self, forKey: .symbol)
        name = try container.decode(String?.self, forKey: .name)
        color = try container.decode(String?.self, forKey: .color)
        iconUrl = try container.decode(String?.self, forKey: .iconUrl)
        marketCap = try container.decode(Float?.self, forKey: .marketCap)
        price = try container.decode(Float?.self, forKey: .price)
        tier = try container.decode(Int?.self, forKey: .tier)
        change = try container.decode(Float?.self, forKey: .change)
        rank = try container.decode(Int?.self, forKey: .rank)
        sparkline = try container.decode([Float]?.self, forKey: .sparkline)
        lowVolume = try container.decode(Bool?.self, forKey: .lowVolume)
        coinrankingUrl = try container.decode(String?.self, forKey: .coinrankingUrl)
        btcPrice = try container.decode(Float?.self, forKey: .btcPrice)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(color, forKey: .color)
        try container.encode(iconUrl, forKey: .iconUrl)
        try container.encode(_24hVolume, forKey: ._24hVolume)
        try container.encode(marketCap, forKey: .marketCap)
        try container.encode(price, forKey: .price)
        try container.encode(tier, forKey: .tier)
        try container.encode(change, forKey: .change)
        try container.encode(rank, forKey: .rank)
        try container.encode(sparkline, forKey: .sparkline)
        try container.encode(lowVolume, forKey: .lowVolume)
        try container.encode(coinrankingUrl, forKey: .coinrankingUrl)
        try container.encode(btcPrice, forKey: .btcPrice)
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

class CrybseCoinDescription:Codable{
    var header:String?
    var body:String?
    
    var Header:String{
        return self.header ?? "No Header"
    }
    
    var Body:String{
        return self.body ?? "No Body"
    }
}

class CrybseCoinAdditionalData:Codable{
    
    class CrybseCoinAdditionalSocialData:Codable{
        var explorer:[String]?
        var facebook:[String]?
        var reddit:[String]?
        var source_code:[String]?
        var website:[String]?
        var youtube:[String]?
    }
    
    class CrybseCoinAdditionalWhitepaper:Codable{
        var link:String?
        var thumbnail:String?
    }
    
    
    var id:String?
    var name:String?
    var symbol:String?
    var rank:Int?
    var is_new:Bool?
    var is_active:Bool?
    var type:String?
    var description:String?
    var open_source:Bool?
    var started_at:String?
    var development_status:String?
    var hardware_wallet:Bool?
    var proof_type:String?
    var org_structure:String?
    var hash_algorithm:String?
    var links:CrybseCoinAdditionalSocialData?
    var whitepaper:CrybseCoinAdditionalWhitepaper?
    
    
    var reddit:String?{
        let subRedditName = self.links?.reddit?.first?.split(separator: "/").last?.description
        print("(DEBUG) SubReddit : ",subRedditName)
        return subRedditName
    }
    
}

class CrybseCoinMetaData:ObservableObject,Codable{
    init(){}
    
    class CoinSupply:ObservableObject,Codable{
        @Published var confirmed:Bool?
        @Published var total:Float?
        @Published var circulating:Float?
        
        init(confirmed:Bool? = nil){
            self.confirmed = confirmed
        }
        
        enum CodingKeys:CodingKey{
            case confirmed
            case total
            case circulating
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            confirmed = try container.decode(Bool?.self, forKey: .confirmed)
            total = try container.decode(Float?.self, forKey: .total)
            circulating = try container.decode(Float?.self, forKey: .circulating)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(confirmed, forKey: .confirmed)
            try container.encode(total, forKey: .total)
            try container.encode(circulating, forKey: .circulating)
        }
    }
    
    class CoinLink:ObservableObject,Codable{
        @Published var name:String?
        @Published var type:String?
        @Published var url:String?
        
        init(){}
        
        enum CodingKeys:CodingKey{
            case name
            case type
            case url
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String?.self, forKey: .name)
            type = try container.decode(String?.self, forKey: .type)
            url = try container.decode(String?.self, forKey: .url)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(url, forKey: .url)
        }
    }
    
    class CoinAllTimeHigh:ObservableObject,Codable{
        @Published var price:Float?
        @Published var timestamp:Double?
        
        init(price:Float? = nil,timestamp:Double? = nil){
            self.price = price
            self.timestamp = timestamp
        }
        
        enum CodingKeys:CodingKey{
            case price
            case timestamp
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            price = try container.decode(Float?.self, forKey: .price)
            timestamp = try container.decode(Double?.self, forKey: .timestamp)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(price, forKey: .price)
            try container.encode(timestamp, forKey: .timestamp)
        }
    }
    
   @Published var uuid:String?
   @Published var symbol:String?
   @Published var name:String?
   @Published var description:Array<CrybseCoinDescription>?
   @Published var color:String?
   @Published var iconUrl:String?
   @Published var websiteUrl:String?
   @Published var supply:CoinSupply?
   @Published var links:[CoinLink?]?
   @Published var dailyVolume:Float?
   @Published var allTimeHigh:CoinAllTimeHigh?
   @Published var numberOfMarkets:Int?
   @Published var numberOfExchanges:Int?
   @Published var marketCap:Float?
   @Published var price:Float?
   @Published var tier:Int?
   @Published var change:Float?
   @Published var rank:Int?
   @Published var sparkline:[Float]?
   @Published var lowVolume:Bool?
   @Published var coinrankingUrl:String?
   @Published var btcPrice:Float?
    
    enum CodingKeys:CodingKey{
       case uuid
       case symbol
       case name
       case description
       case color
       case iconUrl
       case websiteUrl
       case supply
       case links
       case dailyVolume
       case allTimeHigh
       case numberOfMarkets
       case numberOfExchanges
       case marketCap
       case price
       case tier
       case change
       case rank
       case sparkline
       case lowVolume
       case coinrankingUrl
       case btcPrice
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String?.self, forKey: .uuid)
        symbol = try container.decode(String?.self, forKey: .symbol)
        name = try container.decode(String?.self, forKey: .name)
        description = try container.decode(Array<CrybseCoinDescription>?.self, forKey: .description)
        color = try container.decode(String?.self, forKey: .color)
        iconUrl = try container.decode(String?.self, forKey: .iconUrl)
        supply = try container.decode(CoinSupply?.self, forKey: .supply)
        links = try container.decode([CoinLink?]?.self, forKey: .links)
        dailyVolume = try container.decode(Float?.self, forKey: .dailyVolume)
        allTimeHigh = try container.decode(CoinAllTimeHigh?.self, forKey: .allTimeHigh)
        numberOfMarkets = try container.decode(Int?.self, forKey: .numberOfMarkets)
        numberOfExchanges = try container.decode(Int?.self, forKey: .numberOfExchanges)
        marketCap = try container.decode(Float?.self, forKey: .marketCap)
        price = try container.decode(Float?.self, forKey: .price)
        change = try container.decode(Float?.self, forKey: .change)
        rank = try container.decode(Int?.self, forKey: .rank)
        sparkline = try container.decode([Float]?.self, forKey: .sparkline)
        coinrankingUrl = try container.decode(String?.self, forKey: .coinrankingUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(color, forKey: .color)
        try container.encode(iconUrl, forKey: .iconUrl)
        try container.encode(websiteUrl, forKey: .websiteUrl)
        try container.encode(supply, forKey: .supply)
        try container.encode(links, forKey: .links)
        try container.encode(dailyVolume, forKey: .dailyVolume)
        try container.encode(allTimeHigh, forKey: .allTimeHigh)
        try container.encode(numberOfMarkets, forKey: .numberOfMarkets)
        try container.encode(numberOfExchanges, forKey: .numberOfExchanges)
        try container.encode(marketCap, forKey: .marketCap)
        try container.encode(price, forKey: .price)
        try container.encode(tier, forKey: .tier)
        try container.encode(change, forKey: .change)
        try container.encode(rank, forKey: .rank)
        try container.encode(sparkline, forKey: .sparkline)
        try container.encode(lowVolume, forKey: .lowVolume)
        try container.encode(coinrankingUrl, forKey: .coinrankingUrl)
        try container.encode(btcPrice, forKey: .btcPrice)
    }
    
    var WebsiteUrl:String{
        return self.websiteUrl ?? ""
    }
    
    var Supply:CoinSupply{
        return self.supply ?? .init()
    }
    
    var Links:[CoinLink]{
        return self.links?.compactMap({$0}) ?? []
    }
    
    var Description:Array<CrybseCoinDescription>{
        return self.description ?? []
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
