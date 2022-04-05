//
//  CrybseTwitterAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/03/2022.
//

import Foundation

enum CrybseTwitterEndpoints:String{
    case tweetDetails = "tweet"
    case tweetsFromUser = "tweets/user"
    case tweetsSearch = "search"
}

class CrybseTwitterAPI:CrybseAssetSocialsAPI{
    
    init(endpoint:CrybseTwitterEndpoints = .tweetDetails,queries:[String:Any]? = nil){
        super.init(type: .twitter, endpoint: endpoint.rawValue, queryItems: queries)
    }
    
    static var shared:CrybseTwitterAPI = .init()
    
    var tweets:[CrybseTweet]?{
        self.data as? [CrybseTweet]
    }
    
    func getTweets(endpoint:CrybseTwitterEndpoints? = nil,queryItems:[String:Any]? = nil,completion:((Data?) -> Void)? = nil){
        self.getAssetSocialData(type: .twitter, endpoint: endpoint?.rawValue, queryItems: queryItems, completion: completion)
        if self.loading{
            self.loading.toggle()
        }
    }
    
}

