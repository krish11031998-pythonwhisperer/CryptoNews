//
//  CurrencyView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/10/2021.
//

import Foundation
import SwiftUI

enum CurrencyViewSection{
    case news
    case txns
    case feed
    case none
}

struct CurrencyView:View{
    @EnvironmentObject var context:ContextData
    var onClose:(()->Void)?
    @State var currency:AssetData = .init()
    var size:CGSize = .init()
    @StateObject var asset_feed:FeedAPI
    var asset_info:AssetAPI
    @State var showSection:CurrencyViewSection = .none
    @StateObject var TAPI:TransactionAPI = .init()
    @StateObject var NAPI:FeedAPI
    @State var refresh:Bool = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(
        name:String? = nil,
        info:AssetData? = nil,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        
        if let info = info{
            self._currency = .init(wrappedValue: info)
        }
        self.onClose = onClose
        self.size = size
        self._NAPI = .init(wrappedValue: .init(currency: [info?.symbol ?? name ?? "BTC"], sources: ["news"], type: .Chronological, limit: 10))
        self._asset_feed = .init(wrappedValue: .init(currency: [info?.symbol ?? name ?? "BTC"], sources: ["twitter","reddit"], type: .Chronological, limit: 10))
        self.asset_info = AssetAPI.shared(currency: info?.symbol ?? name ?? "BTC")
        self._TAPI = .init(wrappedValue: .init())
    }
    
    
    func onAppear(){
        if self.currency.symbol == nil{
            self.getAssetInfo()
        }
        
        if self.asset_feed.FeedData.isEmpty{
            self.asset_feed.getAssetInfo()
        }
        
        if self.TAPI.transactions.isEmpty{
            if let uid = self.context.user.user?.uid, let sym = currency.symbol{
                self.TAPI.loadTransactions(uuid: uid, currency: sym)
            }
        }
        
        if self.NAPI.FeedData.isEmpty{
            self.NAPI.getAssetInfo()
        }
    }
        
    func onCloseSection(){
        if self.showSection != .none{
            withAnimation(.easeInOut) {
                self.showSection = .none
            }
        }
    }
    
    func getAssetInfo(){
        self.refresh = true
        print("(DEBUG) Fetching Data for asset")
         self.asset_info.getUpdateAssetInfo(completion: self.onReceiveNewAssetInfo(asset:))
    }

    func onReceiveNewAssetInfo(asset:AssetData?){
        guard let data = asset else {return}
        DispatchQueue.main.async {
            self.currency = data
            self.refresh = false
            print("(DEBUG): Updated the Asset Data!")
        }
    }
    
    func onReceiveNewAssetInfo(asset:AssetData?,fn:() -> Void){
        guard let data = asset else {return}
            self.currency = data
            fn()
            print("(DEBUG): Updated the Asset Data!")
    }
    
    
    func getAssetInfo(fn: @escaping () -> Void){
        print("(DEBUG) Fetching Data for asset")
        self.asset_info.getUpdateAssetInfo { data in
            self.onReceiveNewAssetInfo(asset: data,fn: fn)
        }
    }
    
    
    func reloadNewsFeed(idx:Int){
        if idx == self.NAPI.FeedData.count - 5{
            print("(DEBUG) Fetching more feedData")
            self.NAPI.getNextPage()
        }
    }
    
    
    func reloadAssetFeed(idx:Int){
        if idx == self.asset_feed.FeedData.count - 5{
            print("(DEBUG) Fetching more feedData")
            self.asset_feed.getNextPage()
        }
    }
    
    
    func feedView(w:CGFloat) -> some View{
        
        LazyScrollView(data: self.asset_feed.FeedData.compactMap({$0 as Any})) { data in
            if let data = data as? AssetNewsData{
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
            }
        }
        .onPreferenceChange(LazyScrollPreference.self) { reload in
            if reload{
                self.asset_feed.getNextPage()
            }
        }
    }
    
    func newsView(w:CGFloat) -> some View{
        LazyScrollView(data: self.NAPI.FeedData.compactMap({$0 as Any})) { data in
            if let news = data as? AssetNewsData{
                NewsStandCard(news: news,size: .init(width: w, height: CardSize.slender.height * 0.5))
            }
        }
        .onPreferenceChange(LazyScrollPreference.self) { reload in
            if reload{
                self.NAPI.getNextPage()
            }
        }
    }
    
    var txnsForAsset:[Transaction]{
        return self.TAPI.transactions.filter({($0.type == "buy" || $0.type == "sell")})
    }
    
    
    func rightSideView() -> AnyView{
        let color = self.context.user.user?.watching.contains(self.currencyHeading) ?? false ? Color.black : Color.white
        let bgcolor = self.context.user.user?.watching.contains(self.currencyHeading) ?? false ? Color.white : Color.black
        return AnyView(HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "heart", color: color , haveBG: true, size: .init(width: 10, height: 10), bgcolor: bgcolor, alignment: .vertical) {
                if let sym = self.currency.symbol, let included = self.context.user.user?.watching.contains(sym), !included{
                    self.context.user.user?.watching.append(sym)
                    self.context.user.updateUser()
                }
            }
        })
    }

    func innerView(w:CGFloat) -> some View{
        let size:CGSize = .init(width: w, height: totalHeight * 0.3)
        return CurrencyDetailView(info: $currency, size: size, asset_feed: $asset_feed.FeedData, news: $NAPI.FeedData, txns: $TAPI.transactions, showSection: $showSection, onClose: self.onClose)
    }
    
    var currencyHeading:String{
        return "\(currency.symbol ?? "BTC")"
    }
    
    @ViewBuilder var mainView:some View{
        if self.showSection == .none{
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: self.currencyHeading, width: totalWidth, onClose: self.onClose, rightView: self.rightSideView, innerView: self.innerView(w:))
                    .refreshableView(width: size.width,hasToRender:self.context.selectedCurrency != nil) { fun in
                        self.getAssetInfo(fn: fun)
                    }
            }
        }else{
            ProgressView()
        }
    }
    
    @ViewBuilder var diff_Views:some View{
        if self.showSection == .feed{
            HoverView(heading: "Feed", onClose: self.onCloseSection) {w in
                self.feedView(w: w)
            }
        }
        if self.showSection == .txns{
            HoverView(heading: "Transactions", onClose: self.onCloseSection) { w in
                TransactionDetailsView(txns: self.txnsForAsset,currency:self.currency.symbol ?? "LTC", currencyCurrentPrice: self.currency.open ?? 0.0,width: w)
            }
        }
        if self.showSection == .news{
            HoverView(heading: "News", onClose: self.onCloseSection) { w in
                self.newsView(w: w)
            }
        }
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            self.mainView
            self.diff_Views
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
    }
    
    
}
