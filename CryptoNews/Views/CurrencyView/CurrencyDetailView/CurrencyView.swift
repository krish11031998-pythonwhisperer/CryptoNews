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
    @State var refreshData:Bool = false
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
    }
    
    
    func onAppear(){
        if self.currency.symbol == nil{
            self.getAssetInfo()
        }
        
        if self.asset_feed.FeedData.isEmpty{
            self.asset_feed.getAssetInfo()
        }
        
        if self.TAPI.transactions.isEmpty{
            self.TAPI.loadTransaction()
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
        self.refreshData = true
        print("(DEBUG) Fetching Data for asset")
         self.asset_info.getUpdateAssetInfo(completion: self.onReceiveNewAssetInfo(asset:))
    }
    
    func onReceiveNewAssetInfo(asset:AssetData?){
        guard let data = asset else {return}
//        DispatchQueue.main.async {
            self.currency = data
            self.refreshData = false
            print("(DEBUG): Updated the Asset Data!")
    }
    
    func onReceiveNewAssetInfo(asset:AssetData?,fn:() -> Void){
        guard let data = asset else {return}
//        DispatchQueue.main.async {
            self.currency = data
            self.refreshData = false
            fn()
            print("(DEBUG): Updated the Asset Data!")
    }
    
    
    func getAssetInfo(fn: @escaping () -> Void){
        self.refreshData = true
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
        } reload: {
            self.asset_feed.getNextPage()
        }
    }
    
    func newsView(w:CGFloat) -> some View{
        LazyScrollView(data: self.NAPI.FeedData.compactMap({$0 as Any})) { data in
            if let news = data as? AssetNewsData{
                NewsStandCard(news: news,size: .init(width: w, height: 150))
            }
        } reload: {
            self.NAPI.getNextPage()
        }
//        return LazyVStack(alignment: .leading, spacing: 10) {
//            ForEach(Array(self.NAPI.FeedData.enumerated()),id: \.offset) { _news in
//                let news = _news.element
//                let idx = _news.offset
//                NewsStandCard(news: news,size: .init(width: w, height: 150))
//                    .onAppear{
//                        self.reloadNewsFeed(idx: idx)
//                    }
//            }
//        }
    }
    
    var txnsForAsset:[Transaction]{
        let symbol = (self.currency.symbol ?? "BTC").lowercased()
        return self.TAPI.transactions.filter({$0.symbol == symbol && ($0.type == "buy" || $0.type == "sell")})
    }
    
    func refreshAsset(){
        let time = floor(self.currency.timeSinceLastUpdate)
        if(time > 60 && !self.refresh){
            print("Getting the new Updated Asset ")
            self.getAssetInfo()
        }
    }
    
    @ViewBuilder var mainView:some View{
        if self.showSection == .none{
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: "\(currency.symbol ?? "BTC")", width: totalWidth, onClose: self.onClose) { w in
                    let size:CGSize = .init(width: w, height: totalHeight * 0.3)
                    CurrencyDetailView(info: $currency, size: size, asset_feed: $asset_feed.FeedData, news: $NAPI.FeedData, txns: $TAPI.transactions, showSection: $showSection,reloadFeed: self.getAssetInfo, onClose: self.onClose)
                }.refreshableView(width: size.width) { fun in
                    if self.refresh && !self.refreshData{
                        self.getAssetInfo(fn: fun)
                    }
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
//        .onReceive(self.timer) { _ in self.refreshAsset()}
//        .onChange(of: refresh) { newValue in
//            print("onChange in CurrencyView")
//            if newValue && !refreshData{
//                self.getAssetInfo()
//            }
//        }
    }
    
    
}
