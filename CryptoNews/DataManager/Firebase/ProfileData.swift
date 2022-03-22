//
//  ProfileData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/11/2021.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore

typealias FeatureSet = Array<String>

enum ProfileClassType:String,Codable{
    case platinium = "platinium"
    case gold = "gold"
    case silver = "silver"
    case bronze = "bronze"
    case iron = "iron"
    case novice = "novice"
}

extension ProfileClassType{
    func getFeatureSet() -> FeatureSet{
        var features:FeatureSet = []
        switch (self){
            case .platinium :
                features =  ["You have access to social feeds","You have access to all the insights","You have access to polls and poll voting","You have free access to all rooms"]
            case .gold :
                features =  ["You have access to social feeds","You have access to general insights","You have access to polls and poll voting","You have free access to some rooms"]
            case .silver :
                features =  ["You have access to social feeds","You have access to specific general the insights","You have access to polls and poll voting","You dont have access to rooms (provided with entry fee payment)"]
            case .bronze:
                 features = ["You have access to social feeds","You have no access to insights","You have access to polls and poll voting","You have no access to rooms"]
            case .iron:
                features = ["You have access to social feeds","You have no access to insights","You don't have access to polls","You have not access to rooms"]
            case .novice:
                features = ["You have access to social feeds"]
            default:
                print("(DEBUG) Not the right classType")
        }
        features.append("You have a points multiplier \(self.classMultiplier())")
        return features
    }
    
    func getRequirements() -> FeatureSet{
        var features:FeatureSet = []
        switch (self){
            case .platinium :
                features =  ["Hold upto 500 CrybCoins","Like 500 posts","You have access to polls and poll voting","You have free access to all rooms"]
            case .gold :
                features =  ["You have access to social feeds","You have access to general insights","You have access to polls and poll voting","You have free access to some rooms"]
            case .silver :
                features =  ["You have access to social feeds","You have access to specific general the insights","You have access to polls and poll voting","You dont have access to rooms (provided with entry fee payment)"]
            case .bronze:
                 features = ["You have access to social feeds","You have no access to insights","You have access to polls and poll voting","You have no access to rooms"]
            case .iron:
                features = ["You have access to social feeds","You have no access to insights","You don't have access to polls","You have not access to rooms"]
            case .novice:
                features = ["You have access to social feeds"]
            default:
                print("(DEBUG) Not the right classType")
        }
        features.append("You have a points multiplier \(self.classMultiplier())")
        return features
    }
    
    
    func emojiConverter() -> ProfileClassEmoji{
        switch(self){
            case .novice:
                return .novice
            case .iron:
                return .iron
            case .bronze:
                return .bronze
            case .silver:
                return .silver
            case .gold:
                return .gold
            case .platinium:
                return .platinium
            default:
                return .novice
        }
    }
    
    func classMultiplier() -> Float{
        var multiplier:Float = 0
        switch(self){
            case .platinium:
                multiplier = 5
            case .gold:
                multiplier = 3.5
            case .silver:
                multiplier = 2
            case .bronze:
                multiplier = 1.25
            case .novice:
                multiplier = 1
            default:
                multiplier = 1
        }
        return multiplier
    }
}

enum ProfileClassEmoji:String{
    case platinium = "seal"
    case gold = "octagon"
    case silver = "hexagon"
    case bronze = "pentagon"
    case iron = "diamond"
    case novice = "oval.portrait"
}

class ProfileClass:Codable{
    
    var profileClassType:ProfileClassType? = nil

    init(profileClassType:ProfileClassType = .novice){
        self.profileClassType = profileClassType
    }
    
    var cryptoMultiplier:Float{
        var multiplier:Float = 1
        if let profileClass = self.profileClassType {
            switch(profileClass){
                case .platinium:
                    multiplier = 5
                case .gold:
                    multiplier = 3.5
                case .silver:
                    multiplier = 2
                case .bronze:
                    multiplier = 1.25
                case .novice:
                    multiplier = 1
                default:
                    multiplier = 1
            }
        }
        return multiplier
    }
    
    var convertEmojiValue:ProfileClassEmoji{
        if let safeProfileClass = self.profileClassType {
            switch(safeProfileClass){
                case .novice:
                    return .novice
                case .iron:
                    return .iron
                case .bronze:
                    return .bronze
                case .silver:
                    return .silver
                    
                case .gold:
                    return .gold
                case .platinium:
                    return .platinium
                default:
                    return .novice
            }
        }else{
            return .novice
        }
    }
}

class ProfileData:Codable,Loopable{
    var id:String?
    var uid:String?
    var name:String?
    var userName:String?
    var email:String?
    var img:String?
    var info_coins:Float?
    var location:String?
    var dob:String?
    var followers:Int
    var watching:[String]
    var profileClass:ProfileClass?
    init(
        uid:String? = nil,
        name:String?  = nil,
        userName:String? = nil,
        email:String? = nil,
        img:String? = nil,
        info_coins:Float? = nil,
        location:String? = "Dubai, UAE",
        dob:String? = "11 March 1998",
        followers:Int = 1000,
        watching:[String] = ["LTC"]
    ){
        self.uid = uid
        self.name = name
        self.userName = userName
        self.email = email
        self.img = img
        self.info_coins = info_coins
        self.location = location
        self.dob = dob
        self.followers = followers
        self.watching = watching
    }
    
    
    var userInfoKeys:[String]{
        return ["Followers","Following","i.nfo Rank","Location","Date of Birth"]
    }
    
    var userInfo:[String:String]{
        var data:[String:String] = [:]
        data["Followers"] = String(self.followers)
        data["Following"] = String(230)
        data["i.nfo Rank"] = String(3423)
//        data["Location"] = self.location ?? "NYC"
//        data["Date of Birth"] = self.dob ?? Date().stringDate()
        return data
    }
    
    
    static var test:ProfileData = .init(name: "Krishna K Venkatramani", userName: "thecryptoknight", email: "thecryptoknight@gmail.com", info_coins: 100)
    
    static func parseData(document:QueryDocumentSnapshot) -> ProfileData?{
        var res:ProfileData? = nil
        do{
            res = try document.data(as: ProfileData.self)
        }catch{
            print("Error while parsing the ProfileData : ",error.localizedDescription)
        }
        return res
    }
}

class ProfileAPI:FirebaseAPI{
    
    @Published var user:ProfileData? = nil
    
    init(){
        super.init(collection: "users")
    }
    
    static var shared:ProfileAPI = .init()
    
    func getUser(){
        self.loadData()
    }
    
    override func parseData(data: [QueryDocumentSnapshot]) {
        if let userdoc = data.first{
            DispatchQueue.main.async {
                self.user = ProfileData.parseData(document: userdoc)
            }
        }
    }
    
    func createUser(user:ProfileData,completion: @escaping () -> Void){
        do{
            let data = try user.allKeysValues(obj: nil)
            self.uploadTransaction(data: data) { err in
                if let errStr = err?.localizedDescription {
                    print("Error while creating an User : ",errStr)
                }
                completion()
            }
        }catch{
            print("Error while trying to parse the profileData into [String:Data]");
        }
        
    }
    
    func updateUser(user:ProfileData){
        guard let id = user.id else {return}
        do{
            let data = try user.allKeysValues(obj: nil)
            db.collection("users")
                .document(id)
                .updateData(data) { err in
                    if let errStr = err?.localizedDescription{
                        print("Error while updating the User Data : ",errStr)
                    }
                }
            
        }catch{
            print("There is a error when updateProfileData : ",error.localizedDescription)
        }
    }
    
    
}
