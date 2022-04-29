//
//  CrybseCoinData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/12/2021.
//

import Foundation
import Combine
import SwiftUI

// MARK: - CrybseCoinData
class CrybseCoinDataResponse:Codable{
    var data:CrybseCoinSocialData?
    var success:Bool
    
    init(data:CrybseCoinSocialData? = nil,success:Bool = false){
        self.data = data
        self.success = success
    }
    
}

class CrybseEventData:Codable{
    var event_name:String?
    var event_id:String?
    var news_items:Int?
    var date:String?
    var tickers:[String]?
}

typealias CrybseEvents = Array<CrybseEventData>

class CrybseSentimentData:Codable{
    
    struct SentimentalBreakdown{
        var name:String
        var color:Color
        var count:Int
    }
    
    var positive:Int?
    var negative:Int?
    var neutral:Int?
    var sentiment_score:Float?
    
    var Postive:Int{
        return self.positive ?? 0
    }
    
    var Negative:Int{
        return self.negative ?? 0
    }
    
    var Neutral:Int{
        return self.neutral ?? 0
    }
    
    var SentimentScore:Float{
        return self.sentiment_score ?? 0.0
    }
    
    var sentimentBreakdown:[SentimentalBreakdown]{
        return [
            SentimentalBreakdown(name: "Positive", color: .green, count: self.positive ?? 0),
            SentimentalBreakdown(name: "Negative", color: .red, count: self.negative ?? 0),
            SentimentalBreakdown(name: "Neutral", color: .gray, count: self.neutral ?? 0)
        ]
    }
}

class CrybseSentiment:Codable{
    var total: CrybseSentimentData?
    var timeline:[String:CrybseSentimentData]?
    
    var TimelineSorted:[CrybseSentimentData]?{
        guard let timeline = timeline else {
            return nil
        }
        
        return timeline.sorted { s1, s2 in
            func dateFormater(date:String) -> Date{
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "YYYY-MM-dd"
                return outputFormatter.date(from: date) ?? Date()
            }
            
            let s1Date = dateFormater(date: s1.key)
            let s2Date = dateFormater(date: s2.key)
            
            return s1Date < s2Date
        }.compactMap({$1})

    }
    
    var TimelineKeysSorted:[String]?{
        guard let timeline = timeline else {
            return nil
        }
        
        return timeline.sorted { s1, s2 in
            func dateFormater(date:String) -> Date{
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "YYYY-MM-dd"
                return outputFormatter.date(from: date) ?? Date()
            }
            
            let s1Date = dateFormater(date: s1.key)
            let s2Date = dateFormater(date: s2.key)
            
            return s1Date < s2Date
        }.compactMap({$0.key})

    }
}


class CrybseCoinSocialData:ObservableObject,Codable{
    @Published var tweets: Array<CrybseTweet>?
    @Published var metaData:CrybseCoinMetaData?
    @Published var prices:CrybseCoinPrices?
    @Published var sentiment:CrybseSentiment?
    @Published var events:CrybseEvents?
    @Published var news:CrybseNewsList?
    @Published var additionalInfo:CrybseCoinAdditionalData?
    @Published var youtube:CrybseVideosData?
    @Published var reddit:CrybseRedditPosts?
    
    var cancellable:AnyCancellable? = nil
    
    init(){
        self.cancellable = self.metaData?.objectWillChange.sink(receiveValue: { _ in
            withAnimation(.easeInOut) {
                self.objectWillChange.send()
            }
        })
    }
    
    enum CodingKeys:CodingKey{
        case tweets
        case metaData
        case timeSeriesData
        case news
        case prices
        case additionalInfo
        case youtube
        case reddit
        case sentiment
        case events
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tweets = try container.decodeIfPresent(Array<CrybseTweet>.self, forKey: .tweets)
        metaData = try container.decodeIfPresent(CrybseCoinMetaData.self, forKey: .metaData)
        news = try container.decodeIfPresent(CrybseNewsList.self, forKey: .news)
        prices = try container.decodeIfPresent(CrybseCoinPrices.self, forKey: .prices)
        additionalInfo = try container.decodeIfPresent(CrybseCoinAdditionalData.self, forKey: .additionalInfo)
        youtube = try container.decodeIfPresent(CrybseVideosData.self, forKey: .youtube)
        reddit = try container.decodeIfPresent(CrybseRedditPosts.self, forKey: .reddit)
        sentiment = try container.decodeIfPresent(CrybseSentiment.self, forKey: .sentiment)
        events = try container.decodeIfPresent(CrybseEvents.self, forKey: .events)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tweets, forKey: .tweets)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(news, forKey: .news)
        try container.encode(prices,forKey: .prices)
        try container.encode(additionalInfo,forKey: .additionalInfo)
        try container.encode(reddit,forKey: .reddit)
        try container.encode(youtube,forKey: .youtube)
        try container.encode(sentiment,forKey: .sentiment)
        try container.encode(events, forKey: .events)
    }
    
    static func parseCoinDataFromData(data:Data) -> CrybseCoinSocialData?{
        var coinData:CrybseCoinSocialData? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinDataResponse.self, from: data)
            if let data = res.data, res.success{
                coinData = data
            }else{
                print("(DEBUG) Error while trying to get the CrybseCoinSocialData : ")
            }
        }catch{
            print("(DEBUG) Error while trying to parse the CrybseCoinSocialDataResponse : ",error.localizedDescription)
        }
        
        return coinData
    }
    
    var Tweets: Array<CrybseTweet>{
        get{
            return self.tweets ?? []
        }
        
        set{
            self.tweets = newValue
        }
    }
    
    var MetaData:CrybseCoinMetaData{
        get{
            return self.metaData ?? .init()
        }
        
        set{
            self.metaData = newValue
        }
    }
        
    var News:Array<CrybseNews>{
        get{
            return self.news ?? []
        }
        
        set{
            self.news = newValue
        }
    }
    
    var Events:CrybseEvents{
        get{
            return self.events ?? []
        }
        
        set{
            self.events = newValue
        }
    }
    
    var Sentiment:CrybseSentiment{
        get{
            return self.sentiment ?? .init()
        }
        
        set{
            self.sentiment = newValue
        }
    }
    
    var RedditPosts:CrybseRedditPosts{
        get{
            return self.reddit ?? []
        }
        
        set{
            self.reddit = newValue
        }
    }
    
    
    var Videos:CrybseVideosData{
        get{
            return self.youtube ?? []
        }
        
        set{
            return self.youtube = newValue
        }
    }
    
}
