//
//  CoinRankAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import Foundation
enum CoinRankAPIEndpoint:String{
    case coin = "coin"
    case coins = "coins"
}


class CoinRankAPI:DAPI{
    
    override var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.coinranking.com"
        uC.path = "/v2"
        return uC
    }
    
    var requestHeaders:[String:String]{
        return ["x-access-token" : "coinrankinge9c275248410900dc5de5ec0cde224caa8b55cfe7bc4eb2f"]
    }
    
}
