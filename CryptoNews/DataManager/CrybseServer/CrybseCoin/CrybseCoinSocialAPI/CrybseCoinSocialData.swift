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


class CrybseCoinSocialData:ObservableObject,Codable{
    @Published var tweets: Array<CrybseTweet>?
    @Published var metaData:CrybseCoinMetaData?
    @Published var prices:CrybseCoinPrices?
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
    }
    
//    var TimeSeriesData:[CryptoCoinOHLCVPoint]{
//        get{
//            return self.TimeseriesData
//        }
//
//        set{
//            self.TimeseriesData = newValue
//        }
//
//    }
    
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
