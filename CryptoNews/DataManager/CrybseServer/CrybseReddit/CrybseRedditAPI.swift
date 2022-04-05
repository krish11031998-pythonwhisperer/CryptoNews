//
//  CrybseRedditAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import Foundation

class CrybseRedditAPI:CrybseAssetSocialsAPI{
    
    init(subReddit:String? = nil,search:String = "",after:String? = nil,before:String? = nil,time:String = "day",sort:String = "hot",limit:Int = 10){
        let queryItems:[String:Any] = ["subreddit":subReddit,"search":search,"after":after,"before":before,"limit":"\(limit)","time":time,"sort":sort]
        super.init(type: .reddit, queryItems: queryItems)
    }
    
    
    static var shared:CrybseRedditAPI = .init()
    
    var posts:CrybseRedditPosts{
        if let redditPosts = self.data as? CrybseRedditPosts{
            return redditPosts
        }else{
            return []
        }
    }
    
    
    func getRedditPosts(subReddit:String? = nil,search:String? = nil,after:String? = nil,before:String? = nil,limit:Int = 10,completion:((Data?) -> Void)? = nil){
        self.getAssetSocialData(type: .reddit, queryItems:  ["subreddit":subReddit,"search":search,"after":after,"before":before,"limit":"\(limit)"], completion: completion)
        if self.loading{
            self.loading.toggle()
        }
    }
}
