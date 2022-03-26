//
//  CrybseTwitterData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/03/2022.
//

import Foundation

class CrybseTweetsResponse:Codable{
    var data:[CrybseTweet]?
    var success:Bool
    var error:String?
}

class CrybseTweet:Codable,Equatable{
    
    static func == (lhs: CrybseTweet, rhs: CrybseTweet) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id:String?
    var created_at:String?
    var text:String?
    var publicMetric:CrybseTweetPublicMetric?
    var attachments:[CrybseTweetAttachment]?
    var user:CrybseTweetUser?
    var entity:CrybseTweetEntity?
    var sentiment:Float?
    
    var User:CrybseTweetUser{
        return self.user ?? .init()
    }
    
    var CreatedAt:String{
        if let safeStrDate = self.created_at{
            return Date.date_from_string(str_Date: safeStrDate)
        }else{
            return Date().stringDateTime()
        }
    }
    
    var Like:Int{
        return self.publicMetric?.like ?? 0
    }
    
    var Comments:Int{
        return self.publicMetric?.reply_count ?? 0
    }
    
    var Retweet:Int{
        return self.publicMetric?.retweet_count ?? 0
    }
    
    var Text:String{
        return self.text ?? "No Text"
    }
    
    var Sentiment:Float{
        return self.sentiment ?? 3.0
    }
}

typealias CrybseTweets = [CrybseTweet]

extension CrybseTweets{
    
    static func parseTweetsFromData(data:Data) -> CrybseTweets?{
        var tweets:CrybseTweets? = nil
        let decoder = JSONDecoder()
        
        do{
            let response = try decoder.decode(CrybseTweetsResponse.self, from: data)
            if let safeTweets = response.data, response.success{
                tweets = safeTweets
            }
        }catch{
            print("(DEBUG) Error while trying to parse the tweets Data : ",error.localizedDescription)
        }
        return tweets
    }
}

class CrybseTweetUser:Codable{
    var verified:Bool?
    var username:String?
    var id:String?
    var profile_image_url:String?
    var name:String?
}

class CrybseTweetAttachment:Codable{
    var public_metrics:CrybseTweetPublicMetric?
    var media_key:String?
    var duration:Int?
    var width:Int?
    var preview_image_url:String?
    var type:String?
    var height:Int?
}

class CrybseTweetPublicMetric:Codable{
    var view_count:Int?
    var like:Int?
    var retweet_count: Int?
    var reply_count: Int?
    var like_count: Int?
    var quote_count: Int?
}

class CrybseTweetEntity:Codable{
    var urls:[CrybseTweetURLEntity]?
    var cashtags:[TweetHashTag]?
    var hashtags:[TweetHashTag]?
    var annotations:[TweetEntityAnnotation]?
}

class CrybseTweetURLEntity:Codable{
    var url:String
    var expanded_url:String
    var display_url:String
    var image:[EntityImage]?
    var title:String
    var description:String
    var unwound_url:String
}

class EntityImage:Codable{
    var url:String
}

class TweetHashTag:Codable{
    var tag:String
}

class TweetEntityAnnotation:Codable{
    var probability:Float
    var `type`:String
    var normalized_text:String
}
