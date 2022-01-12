//
//  CrybPostData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/12/2021.
//

import SwiftUI
import Combine
import FirebaseAuth
import Firebase
import FirebaseFirestore

class CrybPostBacker:Codable{
    
    private var user_uid:String?
    private var userName:String?
    private var img:String?
    private var stakedVal:Float?
    
    init(
        user_uid:String = "\(Int.random(in: 0...1000))",
        userName:String = "johnDoe",
        img:String = "",
        stakedVal:Float = 100.0
    ){
        self.user_uid = user_uid
        self.userName = userName
        self.img = img
        self.stakedVal = stakedVal
    }
    
    var User_Uid:String{
        return self.user_uid ?? ""
    }
    
    var UserName:String{
        return self.userName ?? ""
    }
    
    var Img:String{
        return self.img ?? ""
    }
    
    var StakedValue:Float{
        return self.stakedVal ?? 0
    }
    
    var decoded:[String:Any]{
        return ["user_uid":self.User_Uid,"userName":self.UserName,"img":self.Img,"stakedVal":self.StakedValue]
    }
}


class CrybPostPrediction:Codable{

    private var coin:String?
    private var price:Float?
    private var high:Float?
    private var low:Float?
    private var time:Date?
    private var graphData:[Float]?
    
    init(
        coin:String = "BTC",
        price:Float = 51000,
        high:Float = 53000,
        low:Float = 49000,
        graphData:[Float] = Array(repeating: Float(0), count: 15).map({ _ in Float.random(in: 49000...53000)}),
        time:Date = Date()
    ){
        self.coin = coin
        self.price = price
        self.high = high
        self.low = low
        self.time = time
        self.graphData = graphData
    }
    
    var Coin:String{
        return self.coin ?? "XXX"
    }
    
    var Price:Float{
        return self.price ?? 0
    }
    
    var High:Float{
        return self.high ?? 0
    }
    
    var Low:Float{
        return self.low ?? 0
    }
    
    var NormalizedPricePercent:Float{
        return (self.Price - self.Low)/(self.High - self.Low)
    }
    
    var Time:Date{
        return self.time ?? Date()
    }
    
    var GraphData:[Float]{
        return self.graphData ?? []
    }
    
    var decoded:[String:Any]{
        return ["coin":self.Coin,"price":self.Price,"high":self.High,"low":self.Low,"graphData":self.GraphData,"time":self.Time]
    }
}


class CrybPostUser:Codable{
    
    init(uid:String = "1",userName:String = "CryptoKnight",img:String = ""){
        self.user_uid = uid
        self.userName = userName
        self.img = img
    }
    
    private var user_uid:String?
    private var userName:String?
    private var img:String?
    
    var User_Uid:String{
        return self.user_uid ?? ""
    }
    
    var UserName:String{
        return self.userName ?? ""
    }
    
    var Img:String{
        return self.img ?? ""
    }
    
    var decoded:[String:Any]{
        return ["user_uid":self.User_Uid,"userName":self.UserName,"img":self.Img]
    }
}

//struct CrybPostData:Codable{
//    
//    var id:UUID?
//    private var user:CrybPostUser?
//    private var postMessage:String?
//    private var likes:Int?
//    private var comments:Int?
//    private var views:Int?
//    private var pricePrediction:CrybPostPrediction?
//    private var stakers:[CrybPostBacker]?
//    private var postImg:String?
//    
//    init(
//        id:UUID = UUID(),
//        user:CrybPostUser,
//        postMessage:String,
//        likes:Int,
//        comments:Int,
//        pricePrediction:CrybPostPrediction,
//        stakers:Array<CrybPostBacker>,
//        postImg:String?
//    ){
//        self.id = id
//        self.user = user
//        self.postMessage = postMessage
//        self.likes = likes
//        self.comments = comments
//        self.pricePrediction = pricePrediction
//        self.stakers = stakers
//        self.postImg = postImg
//    }
//    
//    var PostImage:String{
//        get{
//            return self.postImg ?? ""
//        }
//        
//        
//        set{
//            if self.postImg != newValue{
//                self.postImg = newValue
//            }
//        }
//    }
//    
//    var PostMessage:String{
//        get{
//            return self.postMessage ?? "No Post Message"
//        }
//        
//        set{
//            self.postMessage = newValue
//        }
//        
//    }
//    
//    var User:CrybPostUser{
//        get{
//            return self.user ?? .init()
//        }
//        
//        set{
//            self.user = newValue
//        }
//        
//    }
//    
//    var Likes:Int{
//        return self.likes ?? 0
//    }
//    
//    var Comments:Int{
//        return self.comments ?? 0
//    }
//    
//    var Coin:String{
//        return self.pricePrediction?.Coin ?? "XXX"
//    }
//    
//    var PricePrediction:CrybPostPrediction{
//        return self.pricePrediction ?? .init()
//    }
//    
//    var Stakers:[CrybPostBacker]{
//        return self.stakers ?? []
//    }
//    
//    var Views:Int{
//        return self.views ?? 0
//    }
//    
//    var decoded:[String:Any]{
//        return ["user":self.User.decoded,"postMessage":self.PostMessage,"likes":self.Likes,"comments":self.Comments,"views":self.Views,"pricePrediction":self.PricePrediction.decoded,"stakers":self.Stakers.map({$0.decoded})]
//    }
//    
//    static var test:CrybPostData{
//        return .init(
//            id:UUID(),
//            user:.init(),
//            postMessage:"",
//            likes:150,
//            comments:20,
//            pricePrediction:.init(),
//            stakers:.init(repeating: .init(userName: "TestStaker", stakedVal: Float.random(in: 10...1500)), count: 15),
//            postImg:nil
//        )
//    }
//
//    static func parseFromQueryData(_ data : QueryDocumentSnapshot) -> CrybPostData?{
//        var res:CrybPostData? = nil
//        do{
//            print(data.data())
//            res = try data.data(as: CrybPostData.self)
//        }catch{
//            print("There was an error while decoding the data!",error.localizedDescription)
//        }
//        return res
//    }
//}
//
