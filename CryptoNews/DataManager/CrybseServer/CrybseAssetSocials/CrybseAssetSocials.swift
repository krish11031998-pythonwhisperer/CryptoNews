//
//  CrybseAssetSocials.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/03/2022.
//

import Foundation

enum CrybseAssetSocialType:String{
    case reddit = "reddit"
    case twitter = "twitter"
    case youtube = "coin/youtube"
    case socialHighlights = "socialHighlights"
}


class CrybseAssetSocialsAPI:CrybseAPI{
    
    @Published var data:Any? = nil
    @Published var nextPageToken:Any? = nil
    var type:CrybseAssetSocialType
    var endpoint:String? = nil
    var queryItems:[String:Any]?
    
    init(type:CrybseAssetSocialType,endpoint:String? = nil,queryItems:[String:Any]?){
        self.type = type
        self.endpoint = endpoint
        self.queryItems = queryItems
        super.init()
    }
    
    var query:[URLQueryItem]?{
        guard let safeQueryItems = self.queryItems else { return nil }
        return self.queryBuilder(queries: safeQueryItems)
    }
    
    func path(type:CrybseAssetSocialType? = nil,endpoint:String? = nil) -> String{
        let safeType = type ?? self.type
        let safeEndPoint = endpoint ?? self.endpoint ?? ""
        return safeEndPoint != "" ? safeType.rawValue + "/" + safeEndPoint : safeType.rawValue
    }
    
    
    func request(type:CrybseAssetSocialType? = nil,endpoint:String? = nil,queryItems:[String:Any]? = nil) -> URLRequest?{
        let safeQueryItems = queryItems != nil ? self.queryBuilder(queries: queryItems!) : self.query
        return self.requestBuilder(path: self.path(type: type, endpoint: endpoint), queries: safeQueryItems)
    }
    
    override func parseData(url: URL, data: Data) {
        setWithAnimation {
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
                case .twitter:
                    if let safeTweetsResponse = CrybseTweets.parseTweetsFromData(data: data),let safeTweets = safeTweetsResponse.tweets{
                        self.data = safeTweets
                        if let safeNextToken = safeTweetsResponse.next_token{
                            self.nextPageToken = safeNextToken
                        }
                    }
            }
            
            if self.loading{
                self.loading.toggle()
            }
        }
    }
    
    func getAssetSocialData(type:CrybseAssetSocialType? = nil,endpoint:String? = nil,queryItems:[String:Any]? = nil,completion:((Data?) -> Void)? = nil){
        guard let safeRequest = self.request(type: type, endpoint: endpoint, queryItems: queryItems) else {
            completion?(nil)
            return
        }
        print("(DEBUG) safeRequest : ",safeRequest.url?.absoluteString)
        self.getData(request: safeRequest, completion: completion)
    }
}


