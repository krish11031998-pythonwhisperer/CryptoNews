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
    
    class SparkLineData:Codable{
        var price:[Float]?
    }
    
    class PriceChange:Codable{
        var aed:Float?
        var btc:Float?
        var ltc:Float?
        var xrp:Float?
        var usd:Float?
    }
    
    class OHLCPointData:Codable{
        var timestamp:Float = 0
        var open:Float = 0
        var high:Float = 0
        var low:Float = 0
        var close:Float = 0
        
        
        init(data:[Float] = Array(repeating: 5, count: 0)){
            
            Array(data.enumerated()).forEach { _point in
                let idx = _point.offset
                let point = _point.element
                
                switch idx{
                    case 0:
                        self.timestamp = point
                    case 1:
                        self.open = point
                    case 2:
                        self.high = point
                    case 3:
                        self.low = point
                    case 4:
                        self.close = point
                    default:
                        break
                }
            }
        }
    }
    
    
    class MarketData:Codable{
        var currency_price:PriceChange?
        var sparkline_7d:SparkLineData?
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
}



class CoinGeckoAsset:CoinGeckoMainData,Identifiable,Codable{
    
    var id:String?
    var symbol:String?
    var name:String?
    var description:Description?
    var image:Image?
    var sentiment_votes_up_percentage : Float?
    var sentiment_votes_down_percentage:Float?
    var market_cap_rank:Int?
    var coingecko_rank:Int?
    var developer_score:Float?
    var community_score:Float?
    var liquidity_score:Float?
    var market_data:MarketData?
    var ohlcData:[OHLCPointData]?
    
    
    func updateData(){
        let shared = CGCoinAPI.shared
        shared.currency = self.id ?? "bitcoin"
        shared.getCoinData { data in
            if let asset = CGCoinAPI.parseCoinData(data: data){
                self.sentiment_votes_up_percentage = asset.sentiment_votes_up_percentage
                self.sentiment_votes_down_percentage = asset.sentiment_votes_down_percentage
                self.market_data = asset.market_data
            }
        }
    }
    
    
    func getOHLCPointsData(){
        let shared = CGAssetOHLCAPI.shared
        shared.asset = self.id ?? "bitcoin"
        shared.getCoinOHLCData { data in
            let points = CGAssetOHLCAPI.parseCoinOHLCData(data: data)
        }
    }
    
    func getOHLCPoint(idx:Int) -> CoinGeckoMainData.OHLCPointData?{
        guard let data = self.ohlcData, idx > 0 && idx < data.count else {return nil}
        return data[idx]
    }

}

class CoinGeckoMarketData:CoinGeckoMainData,Codable{
    var id:String?
    var symbol:String?
    var name:String?
    var image:String?
    var current_price:Float?
    var market_cap:Float?
    var market_cap_rank:Float?
    var total_volume: Float?
    var high_24h:Float?
    var low_24h:Float?
    var price_change_24h:Float?
    var price_change_percentage_24h: Float?
    var market_cap_change_24h: Float?
    var market_cap_change_percentage_24h: Float?
    var circulating_supply: Float?
    var total_supply: Float?
    var max_supply: Float?
    var sparkline_in_7d:SparkLineData?
}

