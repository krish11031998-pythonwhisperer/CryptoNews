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
        data["Location"] = self.location ?? "NYC"
        data["Date of Birth"] = self.dob ?? Date().stringDate()
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
