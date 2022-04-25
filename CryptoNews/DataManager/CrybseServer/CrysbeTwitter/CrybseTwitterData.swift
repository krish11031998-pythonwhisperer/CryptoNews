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

class CrybseTweet:ObservableObject,Codable,Equatable{
    
    static func == (lhs: CrybseTweet, rhs: CrybseTweet) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(){}
    
    @Published var id:String?
    @Published var created_at:String?
    @Published var text:String?
    @Published var publicMetric:CrybseTweetPublicMetric?
    @Published var attachments:[CrybseTweetMedia]?
    @Published var user:CrybseTweetUser?
    @Published var urls:[CrybseTweetURLEntity]?
    @Published var cashtags:[TweetHashTag]?
    @Published var hashtags:[TweetHashTag]?
    @Published var annotations:[TweetEntityAnnotation]?
    @Published var media:[CrybseTweetMedia]?
    @Published var retweetedTweet:CrybseTweet?
    @Published var polls:[CrybseTweetPoll]?
    @Published var places:[CrybseTweetPlace]?
    @Published var sentiment:Float?
    @Published var referenceTweet:CrybseTweetReference?
    
    enum CodingKeys:CodingKey{
        case id
        case created_at
        case text
        case publicMetric
        case attachments
        case user
        case urls
        case cashtags
        case hashtags
        case annotations
        case media
        case retweetedTweet
        case polls
        case places
        case sentiment
        case referenceTweet
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        publicMetric = try container.decodeIfPresent(CrybseTweetPublicMetric.self, forKey: .publicMetric)
        attachments = try container.decodeIfPresent(Array<CrybseTweetMedia>.self, forKey: .attachments)
        user = try container.decodeIfPresent(CrybseTweetUser.self, forKey: .user)
        urls = try container.decodeIfPresent(Array<CrybseTweetURLEntity>.self, forKey: .urls)
        cashtags = try container.decodeIfPresent(Array<TweetHashTag>.self, forKey: .cashtags)
        hashtags = try container.decodeIfPresent(Array<TweetHashTag>.self, forKey: .hashtags)
        annotations = try container.decodeIfPresent(Array<TweetEntityAnnotation>.self, forKey: .annotations)
        media = try container.decodeIfPresent(Array<CrybseTweetMedia>.self, forKey: .media)
        
        retweetedTweet = try container.decodeIfPresent(CrybseTweet.self, forKey: .retweetedTweet)
        polls = try container.decodeIfPresent(Array<CrybseTweetPoll>.self, forKey: .polls)
        places = try container.decodeIfPresent(Array<CrybseTweetPlace>.self, forKey: .places)
        sentiment = try container.decodeIfPresent(Float.self, forKey: .sentiment)
        referenceTweet = try container.decodeIfPresent(CrybseTweetReference.self, forKey: .referenceTweet)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(created_at, forKey: .created_at)
        try container.encode(text, forKey: .text)
        try container.encode(publicMetric, forKey: .publicMetric)
        try container.encode(places,forKey: .places)
        try container.encode(polls,forKey: .polls)
        try container.encode(media,forKey: .media)
        try container.encode(sentiment,forKey: .sentiment)
        try container.encode(user,forKey: .user)
        try container.encode(attachments,forKey: .attachments)
        try container.encode(urls,forKey: .urls)
        try container.encode(cashtags,forKey: .cashtags)
        try container.encode(hashtags,forKey: .hashtags)
        try container.encode(attachments,forKey: .attachments)
        try container.encode(annotations,forKey: .annotations)
        try container.encode(retweetedTweet,forKey: .retweetedTweet)
        try container.encode(referenceTweet,forKey: .referenceTweet)
        
        
    }
    
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
