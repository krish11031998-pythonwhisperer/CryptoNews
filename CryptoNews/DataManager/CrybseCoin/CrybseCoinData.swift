//
//  CrybseCoinData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/12/2021.
//

import Foundation

// MARK: - CrybseCoinData
class CrybseCoinDataResponse:Codable{
    var data:CrybseCoinData?
    var success:Bool
}


class CrybseCoinData:Codable{
    var Tweets: Array<AssetNewsData>?
    var MetaData:CoinData?
    var TimeseriesData:Array<CryptoCoinOHLCVPoint>?
    var News:Array<CryptoNews>?
    
    
    static func parseCoinDataFromData(data:Data) -> CrybseCoinData?{
        var coinData:CrybseCoinData? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinDataResponse.self, from: data)
            if let data = res.data, res.success{
                coinData = data
            }else{
                print("(DEBUG) Error while trying to get the CrybseCoinData : ")
            }
        }catch{
            print("(DEBUG) Error while trying to parse the CrybseCoinDataResponse : ",error.localizedDescription)
        }
        
        return coinData
    }
}
