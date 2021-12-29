//
//  CryptoCompareAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 24/12/2021.
//

import Foundation


class CryptoCompareAPI:DAPI{
    
    override var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "min-api.cryptocompare.com"
        uC.path = "/data/v2"
        uC.queryItems = []
        return uC
    }
    
    var apiKey:String{
        return "aa9ce087dc9c09014e03932babd2bc75d4ac536dccdf068bc2bb4a0d99900cec"
    }
    
    var CCAPI_requestHeaders:[String:String]{
        return ["authorization":"Apikey \(self.apiKey)"]
    }
    
}
