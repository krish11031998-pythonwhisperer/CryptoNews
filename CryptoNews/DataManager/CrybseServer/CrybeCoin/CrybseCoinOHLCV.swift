//
//  CrybseCoinOHLCV.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/01/2022.
//

import Foundation

// MARK: - CryptoCoinOHLCV
struct CryptoCoinOHLCVPoint:Codable{
    var time:Float?
    var high:Float?
    var low:Float?
    var open:Float?
    var close:Float?
    var volume:Float?
    var number_of_trades:Float?
    var vwap:Float?
    var twap:Float?
    
    var Time:Int{
        return Int(self.time ?? 0.0)
    }
}

struct CryptoCoinOHLCV:Codable{
    
    var Aggregated:Bool?
    var TimeFrom: Int?
    var TimeTo:Int?
    var Data:[CryptoCoinOHLCVPoint]?
    
}

struct CryptoCoinOHLCVResponse:Codable{
    var Response:String?
    var Message:String?
    var HasWarning:Bool?
    var Data:CryptoCoinOHLCV?
}

