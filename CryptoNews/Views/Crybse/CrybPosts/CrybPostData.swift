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
