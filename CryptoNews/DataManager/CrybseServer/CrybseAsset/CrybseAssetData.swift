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
        if let assetValues = self.assets?.values.compactMap({$0.Profit}){
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
        assets = try container.decodeIfPresent([String:CrybseAsset].self, forKey: .assets)
        tracked = try container.decodeIfPresent([String].self, forKey: .tracked)
        watching = try container.decodeIfPresent([String].self, forKey: .watching)
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
            if res.success,let data = res.data{
                coinData = data
            }else{
                print("(DEBUG) Error while trying to get the CrybseAssets : ")
            }
        }catch{
            print("(DEBUG) Error while trying to parse the CrybseAssetsResponse : ",error.localizedDescription)
        }
        
        return coinData
    }
    
    func updateAsset(sym:String,txn:Transaction){
        let asset = self.assets?[sym] ?? .init(currency: sym)
        asset.Txns.append(txn)
        asset.Value += txn.Subtotal
        asset.CoinTotal += txn.Asset_Quantity
//        if let price = asset.coinData?.Price{
        asset.Profit += Float((txn.Asset_Quantity * 1.0 - txn.Subtotal)/txn.Subtotal)/Float(asset.Txns.count)
//        }
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
//        let coinDataCondition = lhs.coinData?.Price == rhs.coinData?.Price
//        let coinCondition = lhs.coin?.TimeseriesData.last?.time == rhs.coin?.TimeseriesData.last?.time
        
//        return currencyCondition || txnCondition || coinCondition || coinDataCondition
//        return currencyCondition || txnCondition || coinCondition
        return currencyCondition || txnCondition
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
        value = try container.decodeIfPresent(Float.self, forKey: .value)
        profit = try container.decodeIfPresent(Float.self, forKey: .profit)
        coinTotal = try container.decodeIfPresent(Float.self, forKey: .coinTotal)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        txns = try container.decodeIfPresent(Array<Transaction>.self, forKey: .txns)
        coinData = try container.decodeIfPresent(CrybseCoin.self, forKey: .coinData)
        coin = try container.decodeIfPresent(CrybseCoinSocialData.self,forKey: .coin)
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
            return self.coinData?.current_price ?? self.coin?.metaData?.Price       }
        
        set{
            self.coinData?.current_price = newValue
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
        return self.coinData?.market_cap_rank ?? 0
    }
    
    var MarketCap:Float{
        return self.coinData?.market_cap ?? 0.0
    }
    
    
    var Color:String{
        get{
            return "#FFFFFF"
        }
    }
    
    func updatePriceWithLatestTimeSeriesPrice(timeSeries:Array<CryptoCoinOHLCVPoint>?){
        guard let safeTimeseries = timeSeries, let latestPrice = safeTimeseries.last?.close else {return}
        setWithAnimation {
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
 
class CrybseCoinSparkline:ObservableObject,Codable{
    var price:Array<Float>?
    
    enum CodingKeys:CodingKey{
        case price
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decodeIfPresent(Array<Float>.self, forKey: .price)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(price, forKey: .price)
    }
    
}

class CrybseCoin:ObservableObject,Codable{

    init(){}

    @Published var id:String?
    @Published var symbol:String?
    @Published var name:String?
    @Published var image:String?
    @Published var market_cap:Float?
    @Published var current_price:Float?
    @Published var market_cap_rank:Int?
    @Published var total_volume:Float?
    @Published var high_24h:Float?
    @Published var low_24h:Float?
    @Published var price_change_24h:Float?
    @Published var price_change_percentage_24h:Float?
    @Published var market_cap_change_24h:Float?
    @Published var market_cap_change_percentage_24h:Float?
    @Published var circulating_supply:Float?
    @Published var total_supply:Float?
    @Published var max_supply:Float?
    @Published var ath:Float?
    @Published var ath_change_percentage:Float?
    @Published var ath_date:String?
    @Published var atl:Float?
    @Published var atl_change_percentage:Float?
    @Published var atl_date:String?
    @Published var last_updated:String?
    @Published var sparkline_in_7d:CrybseCoinSparkline?
    @Published var price_change_percentage_1h_in_currency:Float?
    @Published var price_change_percentage_24h_in_currency:Float?
    @Published var price_change_percentage_7d_in_currency:Float?
    
    enum CodingKeys:CodingKey{
       case id
       case symbol
       case current_price
       case market_cap_rank
       case name
       case image
       case market_cap
       case total_volume
       case high_24h
       case low_24h
       case price_change_24h
       case price_change_percentage_24h
       case market_cap_change_24h
       case market_cap_change_percentage_24h
       case circulating_supply
       case total_supply
       case max_supply
       case ath
       case ath_change_percentage
       case ath_date
       case atl
       case atl_change_percentage
       case atl_date
       case last_updated
       case price_change_percentage_1h_in_currency
       case price_change_percentage_24h_in_currency
       case price_change_percentage_7d_in_currency
       case sparkline_in_7d
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        current_price = try container.decodeIfPresent(Float.self, forKey: .current_price)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        market_cap_rank = try container.decodeIfPresent(Int.self, forKey: .market_cap_rank)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        market_cap = try container.decodeIfPresent(Float.self, forKey: .market_cap)
        total_volume = try container.decodeIfPresent(Float.self, forKey: .total_volume)
        high_24h = try container.decodeIfPresent(Float.self, forKey: .high_24h)
        low_24h = try container.decodeIfPresent(Float.self, forKey: .low_24h)
        price_change_24h = try container.decodeIfPresent(Float.self, forKey: .price_change_24h)
        price_change_percentage_24h = try container.decodeIfPresent(Float.self, forKey: .price_change_percentage_24h)
        market_cap_change_24h = try container.decodeIfPresent(Float.self, forKey: .market_cap_change_24h)
        market_cap_change_percentage_24h = try container.decodeIfPresent(Float.self, forKey: .market_cap_change_percentage_24h)
        circulating_supply = try container.decodeIfPresent(Float.self, forKey: .circulating_supply)
        total_supply = try container.decodeIfPresent(Float.self, forKey: .total_supply)
        max_supply = try container.decodeIfPresent(Float.self, forKey: .max_supply)
        
        ath = try container.decodeIfPresent(Float.self, forKey: .ath)
        ath_change_percentage = try container.decodeIfPresent(Float.self, forKey: .ath_change_percentage)
        ath_date = try container.decodeIfPresent(String.self, forKey: .ath_date)
        
        atl = try container.decodeIfPresent(Float.self, forKey: .atl)
        atl_change_percentage = try container.decodeIfPresent(Float.self, forKey: .atl_change_percentage)
        atl_date = try container.decodeIfPresent(String.self, forKey: .atl_date)
        
        sparkline_in_7d = try container.decodeIfPresent(CrybseCoinSparkline.self, forKey: .sparkline_in_7d)
        
        price_change_percentage_1h_in_currency = try container.decodeIfPresent(Float.self, forKey: .price_change_percentage_1h_in_currency)
        price_change_percentage_24h_in_currency = try container.decodeIfPresent(Float.self, forKey: .price_change_percentage_24h_in_currency)
        price_change_percentage_7d_in_currency = try container.decodeIfPresent(Float.self, forKey: .price_change_percentage_7d_in_currency)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(symbol, forKey: .symbol)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(current_price, forKey: .current_price)
        try container.encodeIfPresent(market_cap, forKey: .market_cap)
        try container.encodeIfPresent(market_cap_rank, forKey: .market_cap_rank)
        try container.encodeIfPresent(total_volume, forKey: .total_volume)
        try container.encodeIfPresent(high_24h, forKey: .high_24h)
        try container.encodeIfPresent(low_24h, forKey: .low_24h)
        try container.encodeIfPresent(price_change_24h, forKey: .price_change_24h)
        try container.encodeIfPresent(price_change_percentage_24h, forKey: .price_change_percentage_24h)
        try container.encodeIfPresent(market_cap_change_24h, forKey: .market_cap_change_24h)
        try container.encodeIfPresent(market_cap_change_percentage_24h, forKey: .market_cap_change_percentage_24h)
        try container.encodeIfPresent(circulating_supply, forKey: .circulating_supply)
        try container.encodeIfPresent(total_supply, forKey: .total_supply)
        try container.encodeIfPresent(max_supply, forKey: .max_supply)
        try container.encodeIfPresent(ath, forKey: .ath)
        try container.encodeIfPresent(ath_change_percentage, forKey: .ath_change_percentage)
        try container.encodeIfPresent(ath_date, forKey: .ath_date)
        try container.encodeIfPresent(atl, forKey: .atl)
        try container.encodeIfPresent(atl_change_percentage, forKey: .atl_change_percentage)
        try container.encodeIfPresent(atl_date, forKey: .atl_date)
        try container.encodeIfPresent(atl, forKey: .atl)
        try container.encodeIfPresent(last_updated, forKey: .last_updated)
        try container.encodeIfPresent(sparkline_in_7d, forKey: .sparkline_in_7d)
        try container.encodeIfPresent(price_change_percentage_1h_in_currency.self, forKey: .price_change_percentage_1h_in_currency)
        try container.encodeIfPresent(price_change_percentage_24h_in_currency.self, forKey: .price_change_percentage_24h_in_currency)
        try container.encodeIfPresent(price_change_percentage_7d_in_currency.self, forKey: .price_change_percentage_7d_in_currency)
        
    }
    
//    var Description:String{
//        return self.description ?? ""
//    }
    
    var Symbol:String{
        return self.symbol ?? "XXX"
    }
    
    var Name:String{
        return self.name ?? ""
    }
    
//    var Color:String{
//        return ""
//    }
//
    var Price:Float{
        return self.current_price ?? 0.0
    }
    
    var Sparkline:[Float]{
        guard let safeSparkLine = self.sparkline_in_7d?.price else {return []}
        return safeSparkLine
    }
    
    var Change:Float{
        return self.price_change_percentage_24h ?? 0.0
    }
    
    var SymbolIconURL:String{
        return self.image ?? ""
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
    
    class CrybseDescription:Codable{
        var header:String?
        var body:String?
    }
    
    
    var id:String?
    var name:String?
    var symbol:String?
    var rank:Int?
    var is_new:Bool?
    var is_active:Bool?
    var type:String?
    var description:[CrybseDescription]?
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
            confirmed = try container.decodeIfPresent(Bool.self, forKey: .confirmed)
            total = try container.decodeIfPresent(Float.self, forKey: .total)
            circulating = try container.decodeIfPresent(Float.self, forKey: .circulating)
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
            name = try container.decodeIfPresent(String.self, forKey: .name)
            type = try container.decodeIfPresent(String.self, forKey: .type)
            url = try container.decodeIfPresent(String.self, forKey: .url)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(url, forKey: .url)
        }
    }
    
    class CoinAllTimePrice:ObservableObject,Codable{
        @Published var price:Float?
        @Published var time:String?
        @Published var change:Float?
        
        init(price:Float? = nil,time:String? = nil,change:Float? = nil){
            self.price = price
            self.time = time
            self.change = change
        }
        
        enum CodingKeys:CodingKey{
            case price
            case time
            case change
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            price = try container.decodeIfPresent(Float.self, forKey: .price)
            time = try container.decodeIfPresent(String.self, forKey: .time)
            change = try container.decodeIfPresent(Float.self, forKey: .change)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(price, forKey: .price)
            try container.encode(change, forKey: .change)
            try container.encode(time, forKey: .time)
        }
    }
    
    @Published var id:String?
    @Published var symbol:String?
    @Published var name:String?
    @Published var description:String?
    @Published var categories:[String]?
    @Published var twitter_screen_name:String?
    @Published var subredit_url:String?
    @Published var iconUrl:String?
    @Published var positive_sentiment:Float?
    @Published var negative_sentiment:Float?
    @Published var all_time_high:CoinAllTimePrice?
    @Published var all_time_low:CoinAllTimePrice?
    @Published var market_cap_rank:Int?
    @Published var current_price:Float?
    @Published var circulating_supply:Float?
    @Published var total_supply:Float?
    @Published var price_change_1y:Float?
    @Published var price_change_200d:Float?
    @Published var price_change_60d:Float?
    @Published var price_change_30d:Float?
    @Published var price_change_14d:Float?
    @Published var price_change_7d:Float?
    @Published var price_change_24h:Float?
    @Published var low_24h:Float?
    @Published var high_24h:Float?
    @Published var total_volume:Float?
    @Published var btcPrice:Float?
    @Published var sparkline:[Float]?
    
    enum CodingKeys:CodingKey{
        case id
        case symbol
        case name
        case description
        case categories
        case twitter_screen_name
        case subredit_url
        case iconUrl
        case positive_sentiment
        case negative_sentiment
        case all_time_high
        case all_time_low
        case circulating_supply
        case total_supply
        case price_change_1y
        case price_change_200d
        case price_change_60d
        case price_change_30d
        case price_change_14d
        case price_change_7d
        case price_change_24h
        case low_24h
        case high_24h
        case total_volume
        case btcPrice
        case market_cap_rank
        case current_price
        case sparkline
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        categories = try container.decodeIfPresent([String].self, forKey: .categories)
        twitter_screen_name = try container.decodeIfPresent(String.self, forKey: .twitter_screen_name)
        subredit_url = try container.decodeIfPresent(String.self, forKey: .subredit_url)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        positive_sentiment = try container.decodeIfPresent(Float.self, forKey: .positive_sentiment)
        negative_sentiment = try container.decodeIfPresent(Float.self, forKey: .negative_sentiment)
        all_time_high = try container.decodeIfPresent(CoinAllTimePrice.self, forKey: .all_time_high)
        all_time_low = try container.decodeIfPresent(CoinAllTimePrice.self, forKey: .all_time_low)
        circulating_supply = try container.decodeIfPresent(Float.self, forKey: .circulating_supply)
        total_supply = try container.decodeIfPresent(Float.self, forKey: .total_supply)
        price_change_1y = try container.decodeIfPresent(Float.self, forKey: .price_change_1y)
        price_change_200d = try container.decodeIfPresent(Float.self, forKey: .price_change_200d)
        price_change_60d = try container.decodeIfPresent(Float.self, forKey: .price_change_60d)
        price_change_30d = try container.decodeIfPresent(Float.self, forKey: .price_change_30d)
        price_change_14d = try container.decodeIfPresent(Float.self, forKey: .price_change_14d)
        price_change_7d = try container.decodeIfPresent(Float.self, forKey: .price_change_7d)
        price_change_24h = try container.decodeIfPresent(Float.self, forKey: .price_change_24h)
        market_cap_rank = try container.decodeIfPresent(Int.self, forKey: .market_cap_rank)
        low_24h = try container.decodeIfPresent(Float.self, forKey: .low_24h)
        high_24h = try container.decodeIfPresent(Float.self, forKey: .high_24h)
        total_volume = try container.decodeIfPresent(Float.self, forKey: .total_volume)
        btcPrice = try container.decodeIfPresent(Float.self, forKey: .btcPrice)
        sparkline = try container.decodeIfPresent([Float].self, forKey: .sparkline)
        current_price = try container.decodeIfPresent(Float.self, forKey: .current_price)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(symbol, forKey: .symbol)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(categories, forKey: .categories)
        try container.encodeIfPresent(twitter_screen_name, forKey: .twitter_screen_name)
        try container.encodeIfPresent(subredit_url, forKey: .subredit_url)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
        try container.encodeIfPresent(positive_sentiment, forKey: .positive_sentiment)
        try container.encodeIfPresent(negative_sentiment, forKey: .negative_sentiment)
        try container.encodeIfPresent(all_time_high, forKey: .all_time_high)
        try container.encodeIfPresent(circulating_supply, forKey: .circulating_supply)
        try container.encodeIfPresent(total_supply, forKey: .total_supply)
        try container.encodeIfPresent(price_change_1y, forKey: .price_change_1y)
        try container.encodeIfPresent(price_change_200d, forKey: .price_change_200d)
        try container.encodeIfPresent(price_change_60d, forKey: .price_change_60d)
        try container.encodeIfPresent(price_change_30d, forKey: .price_change_30d)
        try container.encodeIfPresent(price_change_14d, forKey: .price_change_14d)
        try container.encodeIfPresent(price_change_7d, forKey: .price_change_7d)
        try container.encodeIfPresent(price_change_24h, forKey: .price_change_24h)
        try container.encodeIfPresent(market_cap_rank, forKey: .market_cap_rank)
        try container.encodeIfPresent(low_24h, forKey: .low_24h)
        try container.encodeIfPresent(high_24h, forKey: .high_24h)
        try container.encodeIfPresent(total_volume, forKey: .total_volume)
        try container.encodeIfPresent(btcPrice, forKey: .btcPrice)
        try container.encodeIfPresent(current_price, forKey: .current_price)
        try container.encodeIfPresent(sparkline, forKey: .sparkline)
    }
    
//    var WebsiteUrl:String{
//        return self.websiteUrl ?? ""
//    }
    
    var Supply:CoinSupply{
        let supply = CoinSupply(confirmed: true)
        supply.circulating = self.circulating_supply
        supply.total = self.total_supply
        return supply
    }
    
//    var Links:[CoinLink]{
//        return self.links?.compactMap({$0}) ?? []
//    }
    
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
//        return self.color ?? ""
        return ""
    }
    
    var Price:Float{
        return self.current_price ?? 0.0
    }
    
    var Sparkline:[Float]{
        return self.sparkline ?? []
    }
    
    var Change:Float{
        return self.price_change_24h ?? 0.0
    }
    
}

class CrybseCoinPriceMarketData:Codable{
    var price:Float?
    var time:String?
    var change:Float?
}

class CrybseCoinData:Codable{
    var id:String?
    var symbol:String?
    var name:String?
    var description:String?
    var categories:[String]?
    var twitter_screen_name:String?
    var subreddit_url:String?
    var iconUrl:String?
    var positive_sentiment:Float?
    var negative_sentiment:Float?
    var market_cap_rank:Int?
    var current_price:Float?
    var all_time_high:CrybseCoinPriceMarketData?
    var all_time_low:CrybseCoinPriceMarketData?
    var total_volume:Int64?
    var high_24h:Float?
    var low_24h:Float?
    var price_change_24h:Float?
    var price_change_7d: Float?
    var price_change_14d: Float?
    var price_change_30d: Float?
    var price_change_60d: Float?
    var price_change_200d: Float?
    var price_change_1y: Float?
    var total_supply: Float?
    var circulating_supply: Float?
    var sparkline:[Float]?
}
