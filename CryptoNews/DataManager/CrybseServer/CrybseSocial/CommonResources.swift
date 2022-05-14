//
//  CommonResources.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 14/05/2022.
//

import Foundation

struct CrybseOpinions:Codable{
    var bullish:Int
    var bearish:Int
}

struct CrybseReactions:Codable{
    var bad_analysis:Int
    var fake_news:Int
    var overreaction:Int
    var quality_analysis:Int
    var trusted_news:Int
}
