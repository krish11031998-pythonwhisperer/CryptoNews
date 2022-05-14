//
//  CrybseRedditAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import Foundation

enum RedditEndpoint:String{
    case posts = "posts"
}

class CrybseRedditAPI:CrybseAssetSocialsAPI{
    
    
    init(endpoint:RedditEndpoint = .posts,limit:Int = 10){
        super.init(type: .reddit,endpoint: endpoint.rawValue,queryItems: nil)
    }
    
    
    static var shared:CrybseRedditAPI = .init()
    
    var posts:CrybseRedditPosts{
        if let redditPosts = self.data as? CrybseRedditPosts{
            return redditPosts
        }else{
            return []
        }
    }
    
    
    func getRedditPosts(endpoint:RedditEndpoint = .posts,limit:Int = 10,completion:((Data?) -> Void)? = nil){
        self.getAssetSocialData(type: .reddit,endpoint: endpoint.rawValue, completion: completion)
        if self.loading{
            self.loading.toggle()
        }
    }
}
