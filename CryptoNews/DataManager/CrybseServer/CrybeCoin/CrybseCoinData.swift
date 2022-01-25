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
class CrybseCoinSocialDataResponse:Codable{
    var data:CrybseCoinData?
    var success:Bool
    
    init(data:CrybseCoinData? = nil,success:Bool = false){
        self.data = data
        self.success = success
    }
    
}


class CrybseCoinData:ObservableObject,Codable{
    @Published var tweets: Array<AssetNewsData>?
    @Published var metaData:CrybseCoinMetaData?
    @Published var timeSeriesData:Array<CryptoCoinOHLCVPoint>?
    @Published var news:Array<CryptoNews>?
    @Published var tradingSignals:CrybseTradingSignalsData?
    
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
        case tradingSignals
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tweets = try container.decode(Array<AssetNewsData>?.self, forKey: .tweets)
        metaData = try container.decode(CrybseCoinMetaData?.self, forKey: .metaData)
        timeSeriesData = try container.decode(Array<CryptoCoinOHLCVPoint>?.self, forKey: .timeSeriesData)
        news = try container.decode(Array<CryptoNews>?.self, forKey: .news)
        tradingSignals = try container.decode(CrybseTradingSignalsData?.self, forKey: .tradingSignals)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tweets, forKey: .tweets)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(timeSeriesData, forKey: .timeSeriesData)
        try container.encode(news, forKey: .news)
        try container.encode(tradingSignals, forKey: .tradingSignals)
    }
    
    var TimeSeriesData:[CryptoCoinOHLCVPoint]{
        self.TimeseriesData ?? []
    }
    
    static func parseCoinDataFromData(data:Data) -> CrybseCoinData?{
        var coinData:CrybseCoinData? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinSocialDataResponse.self, from: data)
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
    
    var Tweets: Array<AssetNewsData>{
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
    
    var TimeseriesData:Array<CryptoCoinOHLCVPoint>{
        get{
            return self.timeSeriesData ?? []
        }
        
        set{
            self.timeSeriesData = newValue
        }
    }
    
    var News:Array<CryptoNews>{
        get{
            return self.news ?? []
        }
        
        set{
            self.news = newValue
        }
    }
    
    var TradingSignals:CrybseTradingSignalsData{
        get{
            return self.tradingSignals ?? .init()
        }
        
        set{
            self.tradingSignals = newValue
        }
    }
}
