//
//  Data.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
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
//    var average_sentiment:Float?
//    var price_score:Int?
//    var social_score:Float?
//    var sentiment_relative:Float?
//    var news:Int?
//    var social_dominance:Float?
//    var market_dominance:Float?
}

class News:Codable{
    var data:[AssetNewsData]?
}

class AssetNewsData:Identifiable,Codable{
    var lunar_id:Float?
    var time:Float?
    var name:String?
    var symbol:String?
    var social_score:Float?
    var type:String?
    var body:String?
    var commented:Int?
    var likes:Int?
    var retweets:Int?
    var link:String?
    var title:String?
    var twitter_screen_name:String?
    var subreddit:String?
    var profile_image:String?
    var description:String?
    var image:String?
    var thumbnail:String?
    var sentiment:Float?
    var average_sentiment:Float?
    var publisher:String?
    var shares:Float?
    var url:String?
}
