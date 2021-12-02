//
//  CrybPostData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/12/2021.
//

import SwiftUI
import Combine

class CrybPostPrediction:Codable{
    
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
    
    private var coin:String?
    private var price:Float?
    private var high:Float?
    private var low:Float?
    private var time:Date?
    private var graphData:[Float]?
    
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
}

struct CrybPostData:Codable{
    
    init(id:String = "1",user:CrybPostUser = .init(),postMessage:String = "",likes:Int = 150,comments:Int = 20,pricePrediction:CrybPostPrediction = .init()){
        self.id = id
        self.user = user
        self.postMessage = postMessage
        self.likes = likes
        self.comments = comments
        self.pricePrediction = pricePrediction
    }
    
    private var id:String?
    private var user:CrybPostUser?
    private var postMessage:String?
    private var likes:Int?
    private var comments:Int?
    private var pricePrediction:CrybPostPrediction?
    
    var PostMessage:String{
        return self.postMessage ?? "No Post Message"
    }
    
    var User:CrybPostUser{
        return self.user ?? .init()
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
    
    static var test:CrybPostData{
        return .init(postMessage: Array(repeating: "Message", count: 50).reduce("", {"\($0) \($1)"}))
    }
}

