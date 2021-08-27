//
//  FeedAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation

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



enum FeedType:String{
    case Influential = "influential"
    case Chronological = "chronological"
}

class FeedAPI:DAPI,ObservableObject{
    var currency:[String]
    var sources:[String]
    var type:FeedType
    var limit:Int
    let page:Int
    @Published var FeedData:[AssetNewsData] = []
    
    init(currency:[String],sources:[String] = ["twitter","reddit","news","urls"],type:FeedType,limit:Int = 15,page:Int = 0){
        self.currency = currency
        self.sources = sources
        self.type = type
        self.limit = limit
        self.page = page
    }
    
    var tweetURL:URL?{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.lunarcrush.com"
        uC.path = "/v2"
        uC.queryItems = [
            URLQueryItem(name: "data", value: "feeds"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
            URLQueryItem(name: "type", value: self.type.rawValue),
            URLQueryItem(name: "symbol", value: self.currency.joined(separator: ",")),
            URLQueryItem(name: "sources", value: self.sources.joined(separator: ",")),
            URLQueryItem(name: "limit", value: "\(self.limit)"),
            URLQueryItem(name: "page", value: "\(self.page)")
        ]
        return uC.url
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(News.self, from: data)
            if let news = res.data {
                DispatchQueue.main.async {
                    self.FeedData = news
                }
            }
        }catch{
            print("DEBUG MESSAGE FROM DAPI : Error will decoding the data : ",error.localizedDescription)
        }
    }
    
    func getAssetInfo(){
        self.getInfo(_url: self.tweetURL, completion: self.parseData(data:))
    }
    
}
