//
//  UIManagerData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/09/2021.
//

import Foundation
import SwiftUI

enum Tabs:String{
    case home = "homekit"
    case info = "eyeglasses"
    case feed = "TwitterIcon"
    case news = "newspaper.fill"
    case txn = "plus.circle"
    case reddit = "RedditIcon"
    case search = "magnifyingglass"
    case profile = "person.fill"
    case none = ""
}

enum LoginState{
    case signedIn
    case signedOut
    case undefined
}

class ContextData:ObservableObject{
    @Published var showTab:Bool = true
    @Published private var _tab:Tabs = .info
    @Published private var _selectedCurrency:AssetData? = nil
    @Published private var _selectedNews:AssetNewsData? = nil
    @Published private var _selectedPost:CrybPostData? = nil
    @Published private var _selectedSymbol:String? = nil
    @Published private var _addTxn:Bool = false
    @Published private var _prev_tab:Tabs = .none
    @Published var loggedIn:LoginState = .undefined
    @Published var user:User = .init()
    @Published var notification:NotificationModel = NotificationModel()
    @Namespace var animationNamespace
    
    
    init(){
        self.user.signInHandler = self.signInHandler
    }
    
    
    var tab:Tabs{
        get{
            return self._tab
        }
        
        set{
            DispatchQueue.main.async{
                withAnimation(.easeInOut(duration: 0.5)) {
                    if self.prev_tab != self._tab{
                        self.prev_tab = self.tab
                    }
                    self._tab = newValue
                }
            }
            
        }
    }
    
    
    var prev_tab:Tabs{
        get{
            return  self._prev_tab
        }
        
        set{
            DispatchQueue.main.async{
                withAnimation(.easeInOut(duration: 0.5)) {
                    self._prev_tab = newValue
                    
                }
            }
        }
    }
    
    
    var selectedCurrency:AssetData?{
        get{
            return self._selectedCurrency
        }
        
        set{
            DispatchQueue.main.async{
                withAnimation(.easeInOut(duration: 0.5)) {
                    self._selectedCurrency = newValue
                }
            }
        }
    }
    
    var selectedSymbol:String?{
        get{
            return self._selectedSymbol
        }
        
        set{
            DispatchQueue.main.async{
                withAnimation(.easeInOut) {
                    self._selectedSymbol = newValue
                }
            }
        }
    }
    
    var selectedNews:AssetNewsData?{
        get{
            return self._selectedNews
        }
        
        set{
            DispatchQueue.main.async{
                withAnimation(.easeInOut(duration: 0.5)) {
                    self._selectedNews = newValue
                }
            }
        }
    }
    
    var selectedPost:CrybPostData?{
        get{
            return self._selectedPost
        }
        
        set{
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self._selectedPost = newValue
                }
            }
        }
        
    }
    
    var addTxn:Bool{
        get{
            return _addTxn
        }
        set{
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self._addTxn = newValue
                }
            }
        }
    }
    
    func signInHandler(){
        if self.loggedIn != .signedIn{
            self.loggedIn = .signedIn
        }
    }
}
