//
//  CrybseRedditData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import Foundation

class CrybseRedditResponse:Codable{
    var data:CrybseRedditPosts?
    var error:String?
    var success:Bool
}

class CrybseRedditData:Codable{
    var id:String?
    var name:String?
    var created_utc:String?
    var permalink:String?
    var url:String?
    var title:String?
    var selftext:String?
    var likes:Int?
    var score:Int?
    var upvote_ratio:Float?
    var num_comments:Int?
    var subreddit:String?
    var subreddit_id:String?
    var subreddit_name_prefixed:String?
    var author:String?
    
    var Title:String{
        return self.title ?? ""
    }
    
    var SelfText:String{
        return self.selftext ?? ""
    }
    
    var Likes:Int{
        return self.likes ?? 0
    }
    
    var Score:Int{
        return self.score ?? 0
    }
    
    var UpVote_Ratio:Float{
        return self.upvote_ratio ?? 0
    }
    
    var SubReddit:String{
        return self.subreddit ?? ""
    }
    
    var Author:String{
        return self.author ?? ""
    }
    
    var Subreddit_name_prefixed:String{
        return self.subreddit_name_prefixed ?? ""
    }
    
    var URL:String{
        return self.url ?? ""
    }
    
    var Permalink:String{
        return "https://www.reddit.com" + (self.permalink ?? "")
    }
    
    var Created_UTC:String{
        guard let dateStr = self.created_utc else {return Date().stringDateTime()}
        return Date.date_from_string(str_Date: dateStr)
    }
}


typealias CrybseRedditPosts = Array<CrybseRedditData>


extension CrybseRedditPosts{
    static func parseFromData(data:Data) -> CrybseRedditPosts?{
        let decoder = JSONDecoder()
        var posts:CrybseRedditPosts?
        do{
            let response = try decoder.decode(CrybseRedditResponse.self, from: data)
            if let safePosts = response.data, response.success{
                posts = safePosts
            }
        }catch{
            print("(DEBUG) There was an error while trying to parse the reddit posts data from the data : ",error.localizedDescription)
        }
        return posts
    }
}
