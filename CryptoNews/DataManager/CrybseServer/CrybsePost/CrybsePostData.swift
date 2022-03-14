//
//  CrybsePostData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/01/2022.
//

import Foundation

struct CrybseSinglePostResponse:Codable{
    var data:CrybPostData?
    var success:Bool
}

struct CrybsePostResponse:Codable{
    var data:[CrybPostData]?
    var success:Bool
}

struct CrybPostData:Codable,Loopable{
    
    var id:UUID?
    private var user:CrybPostUser?
    private var postMessage:String?
    private var likes:Int?
    private var comments:Int?
    private var bullish:Int?
    private var bearish:Int?
    private var like:Int?
    private var dislike:Int?
    private var fakeNews:Int?
    private var verifiedNews:Int?
    private var justATheory:Int?
    private var view:Int?
    private var pricePrediction:CrybPostPrediction?
    private var currency:String?
    private var image:String?
    private var imageFile:Data?
    var poll:CrybsePollData?
    
    init(
        id:UUID = UUID(),
        user:CrybPostUser,
        postMessage:String
    ){
        self.id = id
        self.user = user
        self.postMessage = postMessage
        self.comments = 0
    }
        
    var PostMessage:String{
        get{
            return self.postMessage ?? "No Post Message"
        }
        
        set{
            self.postMessage = newValue
        }
        
    }
    
    var PostReactions:[CrybsePostReaction:Int]{
        get{
            return [CrybsePostReaction.like:self.Like,
                    CrybsePostReaction.dislike:Dislike,
                    CrybsePostReaction.bullish:Bullish,
                    CrybsePostReaction.bearish:Bearish,
                    CrybsePostReaction.fakeNews:FakeNews,
                    CrybsePostReaction.verifiedNews:VerifiedNews,
                    CrybsePostReaction.speculation:JustATheory
            ]
        }
    }
    
    var PostReactionKeys:[CrybsePostReaction]{
        return [CrybsePostReaction.like,
                CrybsePostReaction.dislike,
                CrybsePostReaction.bullish,
                CrybsePostReaction.bearish,
                CrybsePostReaction.fakeNews,
                CrybsePostReaction.verifiedNews,
                CrybsePostReaction.speculation,
        ]
    }
    
    var User:CrybPostUser{
        get{
            return self.user ?? .init()
        }
        
        set{
            self.user = newValue
        }
        
    }
    
    var ImageURL:String?{
        return self.image
    }
    
    var Poll:CrybsePollData{
        get{
            return self.poll ?? .init()
        }
        
        
        set{
            self.poll = newValue
        }
    }
    
    var pollIsValid:Bool{
        return  self.poll?.question != nil && self.poll?.options != nil
    }
    
    var Likes:Int{
        return self.likes ?? 0
    }
    
    var Comments:Int{
        return self.comments ?? 0
    }
    
    var Coin:String{
        return self.pricePrediction?.Coin ?? "XXX"
    }
    
    var PricePrediction:CrybPostPrediction{
        return self.pricePrediction ?? .init()
    }
    
    var Views:Int{
        return self.view ?? 0
    }
    
    var Bullish:Int{
        get{
            return self.bullish ?? 0
        }
        
        set{
            self.bullish = newValue
        }
    }
    
    var Bearish:Int{
        get{
            return self.bearish ?? 0
        }
        
        set{
            self.bearish = newValue
        }
    }
    
    var Like:Int{
        get{
            return self.like ?? 0
        }
        
        set{
            self.like = newValue
        }
    }
    
    var Dislike:Int{
        get{
            return self.dislike ?? 0
        }
        
        set{
            self.dislike = newValue
        }
    }
    
    var FakeNews:Int{
        get{
            return self.fakeNews ?? 0
        }
        
        set{
            self.fakeNews = newValue
        }
    }
    
    var VerifiedNews:Int{
        get{
            return self.verifiedNews ?? 0
        }
        
        set{
            self.verifiedNews = newValue
        }
    }
    
    var JustATheory:Int{
        get{
            return self.justATheory ?? 0
        }
        
        set{
            self.justATheory = newValue
        }
    }
    
    
    var decoded:[String:Any]{
        return ["user":self.User.decoded,"postMessage":self.PostMessage,"likes":self.Likes,"comments":self.Comments,"views":self.Views,"pricePrediction":self.PricePrediction.decoded]
    }
    
    static func packagePostDataforUploading(postMessage:String,user:CrybPostUser,poll:CrybsePollData? = nil) -> CrybPostData{
        var post = CrybPostData(user: user, postMessage: postMessage)
        post.poll = poll
        return post
    }
    
    static var test:CrybPostData{
        return .init(
            id:UUID(),
            user:.init(),
            postMessage:""
        )
    }
}

