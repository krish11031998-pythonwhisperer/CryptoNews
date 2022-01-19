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
    var data:CrybseCoinSocialData?
    var success:Bool
    
    init(data:CrybseCoinSocialData? = nil,success:Bool = false){
        self.data = data
        self.success = success
    }
    
}


class CrybseCoinSocialData:ObservableObject,Codable{
    @Published var Tweets: Array<AssetNewsData>?
    @Published var MetaData:CrybseSocialCoin?
    @Published var TimeseriesData:Array<CryptoCoinOHLCVPoint>?
    @Published var News:Array<CryptoNews>?
    
    var cancellable:AnyCancellable? = nil
    
    init(){
        self.cancellable = self.MetaData?.objectWillChange.sink(receiveValue: { _ in
            withAnimation(.easeInOut) {
                self.objectWillChange.send()
            }
        })
    }
    
    enum CodingKeys:CodingKey{
        case Tweets
        case MetaData
        case TimeseriesData
        case News
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Tweets = try container.decode(Array<AssetNewsData>?.self, forKey: .Tweets)
        MetaData = try container.decode(CrybseSocialCoin?.self, forKey: .MetaData)
        TimeseriesData = try container.decode(Array<CryptoCoinOHLCVPoint>?.self, forKey: .TimeseriesData)
        News = try container.decode(Array<CryptoNews>?.self, forKey: .News)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Tweets, forKey: .Tweets)
        try container.encode(MetaData, forKey: .MetaData)
        try container.encode(TimeseriesData, forKey: .TimeseriesData)
        try container.encode(News, forKey: .News)
    }
    
    var TimeSeriesData:[CryptoCoinOHLCVPoint]{
        self.TimeseriesData ?? []
    }
    
    static func parseCoinDataFromData(data:Data) -> CrybseCoinSocialData?{
        var coinData:CrybseCoinSocialData? = nil
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
}
