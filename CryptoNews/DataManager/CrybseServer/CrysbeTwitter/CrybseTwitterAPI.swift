//
//  CrybseTwitterAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/03/2022.
//

import Foundation

enum CrybseTwitterEndpoints:String{
    case tweetDetails = "twitter/tweet"
    case tweetsFromUser = "twitter/tweets/user"
    case tweetsSearch = "twitter/search"
}

class CrybseTwitterAPI:CrybseAPI{
    
    @Published var tweets:CrybseTweets? = nil
    
    var endpoint:CrybseTwitterEndpoints
    var queries:[URLQueryItem]?
    
    init(endpoint:CrybseTwitterEndpoints,queries:[URLQueryItem]? = nil){
        self.endpoint = endpoint
        self.queries = queries
    }
    
    
    var request:URLRequest?{
        self.requestBuilder(path: self.endpoint.rawValue, queries: self.queries)
    }
    
    override func parseData(url: URL, data: Data) {
        if let tweets = CrybseTweets.parseTweetsFromData(data: data) {
            setWithAnimation {
                self.tweets = tweets
            }
        }
        
        if self.loading{
            setWithAnimation {
                self.loading.toggle()
            }
        }
    }
    
    func getTweets(endpoint:CrybseTwitterEndpoints? = nil,queries:[URLQueryItem]? = nil,completion:((Data) -> Void)? = nil){
        var request:URLRequest? = self.request
        if let safeEndPoint = endpoint, let safeQueries = queries {
            request = self.requestBuilder(path: safeEndPoint.rawValue, queries: safeQueries)
        }
        print("(DEBUG) Twitter URL : ",request?.url?.absoluteString)
        self.getData(request: request, completion: completion)
        
        
    }
    
}
