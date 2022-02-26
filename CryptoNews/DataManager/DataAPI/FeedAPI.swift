//
//  FeedAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation
import SwiftUI

class News:Codable{
    var data:[AssetNewsData]?
}

class AssetNewsData:Identifiable,Codable{
    
    init(){}
    
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
    
    
    var date:Date{
        guard let time = self.time else {return Date()}
        let epochTime = TimeInterval(time)
        let date = Date(timeIntervalSince1970: epochTime)
        return date
    }
    
    static func parseAssetNewsDatafromCryptoNews(news:CryptoNews) -> AssetNewsData{
        var res:AssetNewsData = .init()
        res.title = news.title
        res.image = news.imageurl
        res.body = news.body
        res.url = news.url
        return res
    }
    
    var Thumbnail:String{
        return self.thumbnail ?? ""
    }
    
    var URL:URL?{
        if let urlStr = self.url{
            return Foundation.URL(string: urlStr)
        }else{
            return nil
        }
    }
}



enum FeedType:String{
    case Influential = "influential"
    case Chronological = "chronological"
}

class FeedAPI:DAPI{
    var currency:[String]
    var sources:[String]
    var type:FeedType
    var limit:Int
    var page:Int
    @Published var FeedData:[AssetNewsData] = []
    static var shared:FeedAPI = .init()
    
    
    init(currency:[String] = ["BTC","LTC","XRP"],sources:[String] = ["twitter","reddit","news","urls"],type:FeedType = .Chronological,limit:Int = 15,page:Int = 0){
        self.currency = currency
        self.sources = sources
        self.type = type
        self.limit = limit
        self.page = page
    }
    
    var tweetURL:URL?{
        var uC = self.baseComponent
        uC.queryItems?.append(contentsOf: [
            URLQueryItem(name: "data", value: "feeds"),
            URLQueryItem(name: "type", value: self.type.rawValue),
            URLQueryItem(name: "symbol", value: self.currency.joined(separator: ",")),
            URLQueryItem(name: "sources", value: self.sources.joined(separator: ",")),
            URLQueryItem(name: "limit", value: "\(self.limit)"),
            URLQueryItem(name: "page", value: "\(self.page)")
        ])
        return uC.url
    }
    
    func fetchNewCurrency(currency:String){
//        DispatchQueue.main.async {
            self.currency = [currency]
            self.FeedData = []
//        }
        self.getAssetInfo()
    }
    
    override func parseData(url:URL,data:Data){
//        DataCache.shared[url] = data
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(News.self, from: data)
            if let news = res.data {
                withAnimation(.easeInOut) {
                    if self.FeedData.isEmpty{
                        self.FeedData = news
                    }else{
                        self.FeedData.append(contentsOf: news)
                    }
                    if self.loading{
                        self.loading = false
                    }
                }
            }
        }catch{
            print("DEBUG MESSAGE FROM DAPI : Error will decoding the data : ",error.localizedDescription)
        }
        DispatchQueue.main.async {
            self.loading = false
        }
        
    }
    
    func getAssetInfo(){
        if !self.loading{
            self.loading = true
            self.getData(_url: self.tweetURL)
        }
        
    }
    
    
    func getNextPage(){
        if !self.loading{
            self.loading = true
            self.page += 1;
            self.getData(_url: self.tweetURL)
        }
        
    }
}
