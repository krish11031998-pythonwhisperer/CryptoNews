//
//  CrybseRedditAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import Foundation



class CrybseRedditAPI:CrybseAPI{
    @Published var posts:CrybseRedditPosts = []
    
    var subReddit:String
    
    init(subReddit:String?){
        self.subReddit = subReddit ?? ""
    }

    func requestGenerator( _ subReddit:String?) -> URLRequest?{
        return self.requestBuilder(path: "reddit", queries: [.init(name: "subreddit", value: subReddit ?? self.subReddit)])
    }
    
    override func parseData(url: URL, data: Data) {
        setWithAnimation {
            if let safePosts = CrybseRedditPosts.parseFromData(data: data){
                self.posts = safePosts
            }
            if self.loading{
                self.loading.toggle()
            }
        }
        
        
    }
    
    func getRedditPosts(subReddit:String? = nil,completion:((Data) -> Void)? = nil){
        guard let safeRequest = self.requestGenerator(subReddit) else {return}
        self.getData(request: safeRequest,completion: completion)
    }
    
}
