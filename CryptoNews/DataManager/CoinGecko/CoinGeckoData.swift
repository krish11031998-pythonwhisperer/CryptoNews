//
//  CoinGeckoData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/10/2021.
//

import Foundation

class CoinGeckoMainData{
    class Description:Codable{
        var en:String?
    }
    
    class Links:Codable{
        var homepage:[String]?
        var twitter_screen_name:String?
        var subreddit_url:String?
    }
    
    
    class Image:Codable{
        var thumb:String?
        var small:String?
        var large:String?
    }
    
    class SparkLinData:Codable{
        var price:[Float]?
    }
    
    class PriceChange:Codable{
        var aed:Float?
        var btc:Float?
        var ltc:Float?
        var xrp:Float?
        var usd:Float?
    }
}



class CoinGeckoAsset:CoinGeckoMainData,Identifiable,Codable{
    
    var id:String?
    var symbol:String?
    var name:String?
    var description:Description?
    var images:Image?
    var sentiment_votes_up_percentage : Float?
    var sentiment_votes_down_percentage:Float?
    var market_cap_rank:Int?
    var coingecko_rank:Int?
    var developer_score:Float?
    var community_score:Float?
    var liquidity_score:Float?
    var sparkline_7d:SparkLinData?
    var price_change_24h_in_currency:PriceChange?
    var price_change_percentage_1h_in_currency:PriceChange?
    var price_change_percentage_24h_in_currency:PriceChange?
    var price_change_percentage_7d_in_currency:PriceChange?
    var price_change_percentage_14d_in_currency:PriceChange?
    var price_change_percentage_30d_in_currency:PriceChange?
    var price_change_percentage_60d_in_currency:PriceChange?
    var price_change_percentage_200d_in_currency:PriceChange?
    var price_change_percentage_1y_in_currency:PriceChange?
    var market_cap_change_24h_in_currency:PriceChange?
    var market_cap_change_percentage_24h_in_currency:PriceChange?
    
    
}

