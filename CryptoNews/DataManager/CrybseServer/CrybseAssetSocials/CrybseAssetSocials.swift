//
//  CrybseAssetSocials.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/03/2022.
//

import Foundation

enum CrybseAssetSocialType:String{
    case socialHighlights = "getAssetSocialSummary"
    case reddit = "reddit"
    case youtube = "coin/youtube"
}


class CrybseAssetSocialsAPI:CrybseAPI{
    
    @Published var data:Any? = nil
    var type:CrybseAssetSocialType
    var queryItems:[String:Any]?
    
    init(type:CrybseAssetSocialType,queryItems:[String:Any]?){
        self.type = type
        self.queryItems = queryItems
        super.init()
    }
    
    var query:[URLQueryItem]?{
        guard let safeQueryItems = self.queryItems else { return nil }
        return self.queryBuilder(queries: safeQueryItems)
    }
    
    
    func request(type:CrybseAssetSocialType? = nil,queryItems:[String:Any]? = nil) -> URLRequest?{
        if let type = type, let queryItems = queryItems{
            return self.requestBuilder(path: type.rawValue, queries: self.queryBuilder(queries: queryItems))
        }else{
            return self.requestBuilder(path: self.type.rawValue, queries: self.query)
        }
    }
    
    override func parseData(url: URL, data: Data) {
        switch(self.type){
            case .socialHighlights:
            if let safeSocialHightlightFeed = CrybseSocialHighlightResponse.parseHighlightsFromData(data: data){
                self.data = safeSocialHightlightFeed
            }
            case .reddit:
                if let safeRedditFeed = CrybseRedditPosts.parseFromData(data: data){
                    self.data = safeRedditFeed
                }
            case .youtube:
                if let safeYoutubeFeed = CrybseVideoResponse.parseVideoDataFromData(data: data){
                    self.data = safeYoutubeFeed
                }
        }
    }
    
    func getAssetSocialData(type:CrybseAssetSocialType? = nil,queryItems:[String:Any]? = nil,completion:((Data?) -> Void)? = nil){
        guard let safeRequest = self.request(type: type, queryItems: queryItems) else {
            completion?(nil)
            return
        }
        print("(DEBUG) safeRequest : ",safeRequest.url?.absoluteString)
        self.getData(request: safeRequest, completion: completion)
    }
    
}
