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


struct CrybPostPoll:Codable{
    var question:String?
    var options:[String]?
}

struct CrybPostData:Codable,Loopable{
    
    var id:UUID?
    private var user:CrybPostUser?
    private var postMessage:String?
    private var likes:Int?
    private var comments:Int?
    private var view:Int?
    private var pricePrediction:CrybPostPrediction?
    private var currency:String?
    private var image:String?
    private var imageFile:Data?
    private var polls:Array<CrybPostPoll>?
    
    init(
        id:UUID = UUID(),
        user:CrybPostUser,
        postMessage:String,
        likes:Int,
        comments:Int,
        pricePrediction:CrybPostPrediction,
        stakers:Array<CrybPostBacker>
    ){
        self.id = id
        self.user = user
        self.postMessage = postMessage
        self.likes = likes
        self.comments = comments
        self.pricePrediction = pricePrediction
    }
        
    var PostMessage:String{
        get{
            return self.postMessage ?? "No Post Message"
        }
        
        set{
            self.postMessage = newValue
        }
        
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
    
    var Polls:Array<CrybPostPoll>{
        return self.polls ?? []
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
    
    var decoded:[String:Any]{
        return ["user":self.User.decoded,"postMessage":self.PostMessage,"likes":self.Likes,"comments":self.Comments,"views":self.Views,"pricePrediction":self.PricePrediction.decoded]
    }
    
    static var test:CrybPostData{
        return .init(
            id:UUID(),
            user:.init(),
            postMessage:"",
            likes:150,
            comments:20,
            pricePrediction:.init(),
            stakers:.init(repeating: .init(userName: "TestStaker", stakedVal: Float.random(in: 10...1500)), count: 15)
        )
    }
}

