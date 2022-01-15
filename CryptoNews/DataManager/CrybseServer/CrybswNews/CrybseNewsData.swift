//
//  CrybseNewsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/01/2022.
//

import Foundation
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
