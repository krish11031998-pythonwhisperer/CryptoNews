//
//  CrybseTwitterData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/03/2022.
//

import Foundation

class CrybseTweetsResponse:Codable{
    var data:CrybseTweets?
    var success:Bool
    var error:String?
}

class CrybseTweetResponse:Codable{
    var data:CrybseTweet?
    var success:Bool
    var error:String?
}

class CrybseTweetReference:Codable{
    var type:String?
    var id:String?
}

class CrybseTweet:Codable,Equatable{
    
    static func == (lhs: CrybseTweet, rhs: CrybseTweet) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id:String?
    var created_at:String?
    var text:String?
    var publicMetric:CrybseTweetPublicMetric?
    var attachments:[CrybseTweetMedia]?
    var user:CrybseTweetUser?
    var urls:[CrybseTweetURLEntity]?
    var cashtags:[TweetHashTag]?
    var hashtags:[TweetHashTag]?
    var annotations:[TweetEntityAnnotation]?
    var media:[CrybseTweetMedia]?
    var retweetedTweet:CrybseTweet?
    var polls:[CrybseTweetPoll]?
    var places:[CrybseTweetPlace]?
    var sentiment:Float?
    var referenceTweet:CrybseTweetReference?
    
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
        if let safeRetweet = self.retweetedTweet, let text = safeRetweet.text{
            return text
        }else{
            return self.text ?? "No Text"
        }
    }
    
    var Sentiment:Float{
        return self.sentiment ?? 3.0
    }
    
    var Entities:[String]{
        var allEntities:[String] = []
        if let safeHashTag = self.hashtags{
            allEntities.append(contentsOf: safeHashTag.compactMap({$0.tag}))
        }
        
        if let safeCashTag = self.cashtags{
            allEntities.append(contentsOf: safeCashTag.compactMap({$0.tag}))
        }
        
        return allEntities
    }
    
    static func parseTweetFromData(data:Data) -> CrybseTweet?{
        var tweet:CrybseTweet? = nil
        let decoder = JSONDecoder()
        
        do{
            let response = try decoder.decode(CrybseTweetResponse.self, from: data)
            tweet = response.data
        }catch{
            print("(DEBUG) There was an error while trying to parse the tweet from the Data : ",error.localizedDescription)
        }
        
        return tweet
    }
}

//typealias CrybseTweets = [CrybseTweet]

class CrybseTweets:Codable{
    var tweets:[CrybseTweet]?
    var next_token:String?
}

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

class CrybseTweetMedia:Codable{
    var public_metrics:CrybseTweetPublicMetric?
    var media_key:String?
    var duration:Int?
    var width:Int?
    var preview_image_url:String?
    var type:String?
    var url:String?
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

class CrybseTweetPoll:Codable{
    var id:String?
    var options:[CrybseTweetPollOption]?
}

class CrybseTweetPollOption:Codable{
    var position:Int?
    var label:String?
    var votes:Int?
}

class CrybseTweetPlace:Codable{
    var full_name:String?
    var id:String?
}

class CrybseTweetEntity:Codable{
    var urls:[CrybseTweetURLEntity]?
    var cashtags:[TweetHashTag]?
    var hashtags:[TweetHashTag]?
    var annotations:[TweetEntityAnnotation]?
}

class CrybseTweetURLEntity:Codable{
    var url:String?
    var expanded_url:String?
    var display_url:String?
    var images:[EntityImage]?
    var title:String?
    var description:String?
    var unwound_url:String?
    
    var Title:String{
        return self.title ?? ""
    }
    
    var Description:String{
        return self.description ?? ""
    }
    
    var Unwound_URL:String{
        return self.unwound_url ?? ""
    }
    
    var DisplayURL:String{
        return self.display_url ?? ""
    }
    
    var ExpandedURL:String{
        return self.expanded_url ?? ""
    }
    
    var URL:String{
        return self.url ?? ""
    }
}

class EntityImage:Codable{
    var url:String?
}

class TweetHashTag:Codable{
    var tag:String?
}

class TweetEntityAnnotation:Codable{
    var probability:Float?
    var `type`:String?
    var normalized_text:String?
}
