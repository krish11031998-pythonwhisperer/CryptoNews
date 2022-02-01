//
//  CrybseCoinAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/01/2022.
//

import Foundation

enum CrybseCoinAPIEndpoints:String{
    case coins = "coins"
    case coinData = "coin/data"
    case coinPrices = "coin/prices"
    case coinLatestPrice = "coin/latestPrice"
}

class CrybseCoinAPI:CrybseAPI{
    var type:CrybseCoinAPIEndpoints
    var params:[String:String]
    init(type:CrybseCoinAPIEndpoints,params:[String:String] = [:]){
        self.type = type
        self.params = params
    }
    
    
    var request:URLRequest?{
        return self.requestBuilder(path: self.type.rawValue, queries: self.params.map({URLQueryItem(name: $0, value: $1)}))
    }
}

//MARK: - CrybseCoinAPI
class CrybseCoinDataAPI:CrybseCoinAPI{
    
    @Published var coinData:CrybseCoin? = nil
    
}
