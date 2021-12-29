//
//  CryptoCompareData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 24/12/2021.
//

import Foundation

// MARK: - CryptoCoinOHLCV
struct CryptoCoinOHLCVPoint:Codable{
    var time:Int?
    var high:Float?
    var low:Float?
    var open:Float?
    var close:Float?
    var volumefrom:Float?
    var volumeto:Float?
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

// MARK: - CryptoNews

struct CryptoNewsSource:Codable{
    var name:String?
    var lang:String?
    var img:String?
}

struct CryptoNews:Codable{
    var id:String?
    var published_on:Int?
    var imageurl:String?
    var title:String?
    var url:String?
    var source:String?
    var body:String?
    var tags:String?
    var categories:String?
    var upvotes:String?
    var downvotes:String?
    var lang:String?
    var source_info:CryptoNewsSource?
}

struct CryptoNewsResponse:Codable{
    var Message:String?
    var Data:[CryptoNews]?
}
