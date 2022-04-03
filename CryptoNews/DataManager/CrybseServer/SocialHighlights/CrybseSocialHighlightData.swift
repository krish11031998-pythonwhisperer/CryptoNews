//
//  SocialHighlightData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/04/2022.
//

import Foundation

class CrybseSocialHighlights:Codable{
    var tweets:[CrybseTweet]?
    var reddit:[CrybseRedditData]?
    
    var Tweets:[CrybseTweet]{
        return self.tweets ?? []
    }
    
    var Reddit:[CrybseRedditData]{
        return self.reddit ?? []
    }
}

class CrybseSocialHighlightResponse:Codable{
    var data:CrybseSocialHighlights?
    var success:Bool
    var err:String?
    
    static func parseHighlightsFromData(data:Data) -> CrybseSocialHighlights?{
        let decoder = JSONDecoder()
        var socialData:CrybseSocialHighlights? = nil
        do{
            let response = try decoder.decode(CrybseSocialHighlightResponse.self, from: data)
            if response.success,let result = response.data{
                socialData = result
            }
        }catch{
            print("(DEBUG) Error while decoding Highlight Response : ",error.localizedDescription)
        }
        return socialData
    }
}
