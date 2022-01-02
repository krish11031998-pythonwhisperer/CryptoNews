//
//  CrybseCoinData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/12/2021.
//

import Foundation

// MARK: - CrybseCoinData
class CrybseCoinSocialDataResponse:Codable{
    var data:CrybseCoinSocialData?
    var success:Bool
}


class CrybseCoinSocialData:Codable{
    var Tweets: Array<AssetNewsData>?
    var MetaData:CrybseCoin?
    var TimeseriesData:Array<CryptoCoinOHLCVPoint>?
    var News:Array<CryptoNews>?
    
    
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
