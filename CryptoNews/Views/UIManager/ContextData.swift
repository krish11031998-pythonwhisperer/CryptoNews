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
    case txn = "doc"
    case post = "message"
    case currency
    case reddit = "RedditIcon"
    case search = "magnifyingglass"
    case profile = "person.fill"
    case portfolio = "waveform"
    case none
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
    @Published var _addButtonPressed:Bool = false
    @Published private var _selectedAsset:CrybseAsset? = nil
    @Published private var _selectedLink:URL? = nil
    @Published private var _selectedPost:CrybPostData? = nil
    @Published private var _selectedTweet:CrybseTweet? = nil
    @Published private var _selectedNews:CrybseNews? = nil
    @Published private var _selectedVideo:CrybseNews? = nil
    @Published private var _showAsset:Bool = false
    @Published private var _showVideo:Bool = false
    @Published private var _showTweet:Bool = false
    @Published private var _showNews:Bool = false
    @Published private var _showReddit:Bool = false
    @Published private var _selectedRedditPost:CrybseRedditData? = nil 
    @Published private var _showSocialHighlights:Bool = false
    @Published private var _selectedSymbol:String? = nil
    @Published private var _showPortfolio:Bool = false
    @Published private var _assetOverTime:CrybseAssetOverTime? = nil
    @Published private var _addTxn:Bool = false
    @Published private var _addPost:Bool = false
    @Published private var _prev_tab:Tabs = .none
    @Published private var _socialHighlightsData:Any? = nil
    @Published var loggedIn:LoginState = .undefined
    @Published private var _user:User = .init()
    @Published private var _userAssets:CrybseAssets = .init()
    @Published var notification:NotificationModel = .init()
    @Published var bottomSwipeNotification:NotificationData = .init()
    @Namespace var animationNamespace

    var notificationCancellable: AnyCancellable? = nil
    var userCancellable:AnyCancellable? = nil
    var userAssetsCancellable:AnyCancellable? = nil
    
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
        
        self.userAssetsCancellable = self._userAssets.objectWillChange.sink(receiveValue: { [weak self] (_) in
            withAnimation(.easeInOut) {
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
                        self.prev_tab = self._tab
                    }
                    self._tab = newValue
                    
                    if newValue == .post{
                        self.addPost.toggle()
                    }else if newValue == .txn{
                        self.addTxn.toggle()
                    }
                }
            }
            
        }
    }
    
    var assetOverTime:CrybseAssetOverTime?{
        get{
            return self._assetOverTime
        }
        
        set{
            setWithAnimation {
                self._assetOverTime = newValue
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
    
    var addButtonPressed:Bool{
        get{
            return _addButtonPressed
        }
        
        set{
            self._addButtonPressed = newValue
        }
    }
    
    
    var selectedAsset:CrybseAsset?{
        get{
            return self._selectedAsset
        }
        
        set{
            self.showAsset = newValue != nil
            self.showTab = newValue == nil
            self._selectedAsset = newValue
        }
    }
    
    var showAsset:Bool{
        get{
            self._showAsset
        }
        
        set{
            self._showAsset = newValue
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
    
    var socialHighlightsData:Any?{
        get{
            return self._socialHighlightsData
        }
        
        
        set{
            self._socialHighlightsData = newValue
            self.showTab = newValue == nil
            self.showSocialHighlights = newValue != nil
        }
    }
    
    
    var selectedPost:CrybPostData?{
        get{
            return self._selectedPost
        }
        
        set{
            setWithAnimation {
                self._selectedPost = newValue
                self.showTab = newValue != nil
            }
        }
        
    }
    
    var selectedVideoData:CrybseNews?{
        get{
            return self._selectedVideo
        }
        
        set{
            self.showTab = newValue == nil
            self.showVideo = newValue != nil
            self._selectedVideo = newValue
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
    
    var selectedTweet:CrybseTweet?{
        get{
            return self._selectedTweet
        }
        
        set{
            self.showTab = newValue == nil
            self.showTweet = newValue != nil
            self._selectedTweet = newValue
        }
    }
    
    var selectedNews:CrybseNews?{
        get{
            return self._selectedNews
        }
        
        set{
            self.showTab = newValue == nil
            self.showNews = newValue != nil
            self._selectedNews = newValue
        }
    }
    
    var showTweet:Bool{
        get{
            return self._showTweet
        }
        
        set{
            if !newValue{
                if self._selectedTweet != nil{
                    self._selectedTweet = nil
                }
                if !self.showTab && self.selectedAsset == nil{
                    self.showTab.toggle()
                }
            }
            self._showTweet = newValue
        }
    }
    
    var showNews:Bool{
        get{
            return self._showNews
        }
        
        set{
            if !newValue{
                if  self._selectedNews != nil{
                    self._selectedNews = nil
                }
                if !self.showTab && self.selectedAsset == nil{
                    self.showTab.toggle()
                }
            }
            self._showNews = newValue
        }
    }
    
    var showVideo:Bool{
        get{
            return self._showVideo
        }
        
        set{
            if !newValue{
                if self._selectedVideo != nil{
                    self._selectedVideo = nil
                }
                if !self.showTab && self.selectedAsset == nil{
                    self.showTab.toggle()
                }
            }
            self._showVideo = newValue
        }
    }
    var selectedReddit:CrybseRedditData?{
        get{
            return self._selectedRedditPost
        }
        
        set{
            self.showTab = newValue == nil
            self.showReddit = newValue != nil
            self._selectedRedditPost = newValue
        }
    }
    
    var showReddit:Bool{
        get{
            return self._showReddit
        }
        
        set{
            if !newValue{
                if self._selectedRedditPost != nil{
                    self._selectedRedditPost = nil
                }
                
                if !self.showTab && self.selectedAsset == nil{
                    self.showTab.toggle()
                }
            }
            
            self._showReddit = newValue
        }
    }
    
    var showPortfolio:Bool{
        get{
            return self._showPortfolio
        }
        
        set{
            setWithAnimation {
                self._showPortfolio = newValue
                
            }
            if newValue && self.showTab{
                self.showTab = false
            }else if !newValue && !self.showTab{
                self.showTab = true
            }
        }
    }
    
    var showSocialHighlights:Bool{
        get{
            self._showSocialHighlights
        }
        
        set{
            self._showSocialHighlights = newValue
            if !newValue && !self.showTab{
                self.showTab.toggle()
            }
            
            if !newValue && self.socialHighlightsData != nil{
                self.socialHighlightsData = nil
            }
            
        }
    }
    
    var Currencies:[String]{
        get{
            return self.user.user?.watching ?? []
        }
    }
    
    var hoverViewEnabled:Bool{
        return !(self.selectedLink == nil && self.selectedPost == nil && self.selectedAsset == nil && self.selectedVideoData == nil && !self.addTxn && !self.addPost)
    }
    
    func AddNewTxn(txn:Transaction){
        let currency = txn.Asset
        if let safeAsset = self.userAssets.assets?[currency]{
            guard let watching = self.userAssets.watching else {return}
            if watching.contains(currency){
                self.userAssets.watching = watching.filter({$0 != currency})
            }
            self.userAssets.assets?[currency] = safeAsset
            self.userAssets.tracked?.append(currency)
        }else{
            CrybseAssetsAPI.shared.getAssets(symbols: [currency], uid: txn.Uid) { assets in
                guard let safeAsset = assets?.assets?[currency] else {return}
                safeAsset.txns = [txn]
                self.userAssets.assets?[currency] = safeAsset
                self.userAssets.tracked?.append(currency)
            }
        }
    }
    
    var selectedLink:URL?{
        get{
            return self._selectedLink
        }
        
        set{
            setWithAnimation {
                if self._selectedLink != newValue{
                    self._selectedLink = newValue
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
