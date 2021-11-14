//
//  User.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/11/2021.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import SwiftUI


class User:ObservableObject{
    
    var signInHandler:(() -> Void)? = nil
    
    init(signInHandler:(() -> Void)? = nil){
        self.signInHandler = signInHandler
    }
    @Published var fir_user:FirebaseAuth.User? = nil{
        didSet{
            if let user = self.fir_user, let uid = self.fir_user?.uid{
                ProfileAPI.shared.loadData(val: uid) { qss, err in
                    guard let user = qss?.documents.first else {return self.updateUser(user: user)}
                    do{
                        let userData = try user.data(as: ProfileData.self)
                        userData?.id = user.documentID
                        self.user = userData
                    }catch{
                        print("(DEBUG) Retrieving the data of the user for the given uid")
                    }
                    
                }
            }
        }
    }
    
    @Published var user:ProfileData? = nil{
        didSet{
            print("profileData : ", user?.uid)
            self.signInHandler?()
        }
    }
    
    
    static var shared:User = .init()
    
    func updateUser(user:FirebaseAuth.User){
        self.user = .init(uid: user.uid,email: user.email)
    }
    
    func updateUser(){
        if let user = self.user{
            ProfileAPI.shared.updateUser(user: user)
        }
    }
    
    func fallBackFn(){
        print("Completed the createUser!")
    }
    
    
    func createUser(completion: (() -> Void)? = nil){
        guard let user = self.user else {return}
        ProfileAPI.shared.createUser(user: user,completion: completion ?? signInHandler ?? fallBackFn)
    }
}
