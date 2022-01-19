//
//  UIManagerData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/09/2021.
//

import Foundation
import SwiftUI
import Combine

enum Tabs:String,Hashable{
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

struct TabBarItem:Hashable{
    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        return lhs.name == rhs.name && lhs.tab == rhs.tab
    }
    
   var name:String = ""
   var tab:String = ""
}

enum LoginState{
    case signedIn
    case signedOut
    case undefined
}

class ContextData:ObservableObject{
    @Published var showTab:Bool = true
    @Published private var _tab:Tabs = .home
    @Published private var _selectedCurrency:CrybseAsset? = nil
    @Published private var _selectedNews:AssetNewsData? = nil
    @Published private var _selectedPost:CrybPostData? = nil
    @Published private var _selectedSymbol:String? = nil
    @Published private var _addTxn:Bool = false
    @Published private var _addPost:Bool = false
    @Published private var _prev_tab:Tabs = .none
    @Published var loggedIn:LoginState = .undefined
    @Published private var _user:User = .init()
    @Published private var _userAssets:CrybseAssets = .init()
    @Published var notification:NotificationModel = NotificationModel()
    @Published var bottomSwipeNotification:NotificationData = .init()
    @Namespace var animationNamespace

    var transactionCancellable: AnyCancellable? = nil
    var notificationCancellable: AnyCancellable? = nil
    var assetCancellable:AnyCancellable? = nil
    var userCancellable:AnyCancellable? = nil
    var coinDataCancellable:AnyCancellable? = nil
    
    init(){
        self.user.signInHandler = self.signInHandler
        self.notificationCancellable = self.bottomSwipeNotification.objectWillChange.sink(receiveValue: { [weak self] (_)in
            withAnimation(.easeInOut) {
                self?.objectWillChange.send()
            }
        })
        self.userCancellable = self._user.objectWillChange.sink(receiveValue: { [weak self] (_) in
            withAnimation(.easeInOut) {
                self?.objectWillChange.send()
            }
        })
        
        self.assetCancellable = self._userAssets.objectWillChange.sink(receiveValue : {[weak self] (_) in
            withAnimation(.easeInOut){
                self?.objectWillChange.send()
            }
        })
        
    }
}


extension ContextData{
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
    
    
    var selectedCurrency:CrybseAsset?{
        get{
            return self._selectedCurrency
        }
        
        set{
            setWithAnimation {
                self._selectedCurrency = newValue
                self.showTab = newValue != nil ? false : true
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
                    self.showTab = newValue != nil ? false : true
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
                    self.showTab = newValue != nil ? false : true
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
                    self.showTab = newValue != nil ? false : true
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
                    self.showTab = newValue ? false : true
                }
            }
        }
    }
    
    var addPost:Bool{
        get{
            return self._addPost
        }
        
        set{
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self._addPost = newValue
                }
            }
        }
    }
    
    var userAssets:CrybseAssets{
        get{
            return self._userAssets
        }
        
        set{
            setWithAnimation {
                self._userAssets = newValue
            }
        }
    }
    
    
    var user:User{
        get{
            return self._user
        }
        
        set{
            setWithAnimation {
                self._user = newValue
            }
        }
    }
    
    func signInHandler(){
        if self.loggedIn != .signedIn{
            self.loggedIn = .signedIn
        }
    }
    
}
