//
//  CrybseRedditAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import Foundation

class CrybseRedditAPI:CrybseAssetSocialsAPI{
    
    init(subReddit:String?,limit:Int = 10){
        super.init(type: .reddit, queryItems: [ "subreddit":subReddit ?? "","limit":"\(limit)"])
    }
    
    
    var posts:CrybseRedditPosts{
        if let redditPosts = self.data as? CrybseRedditPosts{
            return redditPosts
        }else{
            return []
        }
    }
    
    
    func getRedditPosts(subReddit:String? = nil,limit:Int = 10,completion:((Data?) -> Void)? = nil){
        self.getAssetSocialData(type: .reddit, queryItems: subReddit != nil ? ["subreddit":subReddit ?? "","limit":"\(limit)"] : nil, completion: completion)
        
    }
}
