//
//  FirebaseAuth.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/11/2021.
//

import SwiftUI
import FirebaseAuth


class AuthManager{
    
    static var shared:AuthManager = .init()
    
    func signUpUser(email:String,password:String,completionHandler:((FirebaseAuth.User) -> Void)? = nil){
        Auth.auth().createUser(withEmail: email, password: password) { _authResult, err in
            guard let res = _authResult else {return}
            let user = res.user
            print("User : \(user.uid) was created")
            completionHandler?(user)
        }
    }
    
    func signInUser(email:String,password:String,completionHandler:((FirebaseAuth.User) -> Void)? = nil){
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            guard let user = res?.user else {
                if let err_str = err?.localizedDescription{
                    print("Err : ",err_str)
                }
                return
            }
            completionHandler?(user)
        }
    }
    
}
