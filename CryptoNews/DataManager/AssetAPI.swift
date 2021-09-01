//
//  AssetAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation

class Asset:Codable{
    var data:[AssetData]
}

class AssetData:Identifiable,Codable{
    var id:Int?
    var timeSeries:[AssetData]?
    var time:Float?
    var open:Float?
    var high:Float?
    var low:Float?
    var close:Float?
    var volume:Float?
    var name:String?
    var symbol:String?
    var price:Float?
    var price_btc:Float?
    var market_cap:Float?
    var percent_change_24h:Float?
    var percent_change_7d:Float?
    var percent_change_30d:Float?
    var volume_24h:Float?
    var average_sentiment_calc_24h_previous:Float?
    var social_score_calc_24h_previous:Float?
    var social_volume_calc_24h_previous:Float?
    var news_calc_24h_previous:Float?
    var tweet_spam_calc_24h_previous:Float?
    var url_shares_calc_24h_previous:Float?
    var url_shares:Float?
    var unique_url_shares:Float?
    var tweet_spam_calc_24h:Float?
    var tweet_spam_calc_24h_percent:Float?
    var news_calc_24h:Float?
    var tweets:Float?
    var tweet_spam:Float?
    var tweet_followers:Float?
    var tweet_quotes:Float?
    var tweet_retweets:Float?
    var tweet_sentiment1:Int?
    var tweet_sentiment2:Int?
    var tweet_sentiment3:Int?
    var tweet_sentiment4:Int?
    var tweet_sentiment5:Int?
    var tweet_sentiment_impact1:Float?
    var tweet_sentiment_impact2:Float?
    var tweet_sentiment_impact3:Float?
    var tweet_sentiment_impact4:Float?
    var tweet_sentiment_impact5:Float?
    var average_sentiment:Float?
//    var price_score:Int?
//    var social_score:Float?
//    var sentiment_relative:Float?
//    var news:Int?
//    var social_dominance:Float?
//    var market_dominance:Float?
}


class AssetAPI:DAPI,ObservableObject{
    var currency:String
    @Published var data:AssetData? = nil
    
    init(currency:String){
        self.currency = currency
        super.init()
    }
    
    
    var assetURL:URL?{
        var uC = self.baseComponent
        uC.queryItems?.append(contentsOf: [
            URLQueryItem(name: "data", value: "assets"),
            URLQueryItem(name: "symbol", value: self.currency)
        ])
        return uC.url
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(Asset.self, from: data)
            if let first = res.data.first {
                DispatchQueue.main.async {
                    self.data = first
                }
            }
        }catch{
            print("DEBUG MESSAGE FROM DAPI : Error will decoding the data : ",error.localizedDescription)
        }
    }
    
    func getAssetInfo(){
        self.getInfo(_url: self.assetURL, completion: self.parseData(data:))
    }
}
