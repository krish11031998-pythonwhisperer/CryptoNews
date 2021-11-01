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
    @State var assetData:AssetData = .init()
    var size:CGSize = .init()
    @StateObject var TwitterAPI:FeedAPI
    var asset_info:AssetAPI
    @State var showSection:CurrencyViewSection = .none
    @StateObject var TAPI:TransactionAPI = .init()
    @StateObject var NewsAPI:FeedAPI
    @State var refresh:Bool = false
//    @State var refreshData:Bool = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(
        name:String? = nil,
        info:AssetData? = nil,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        if let info = info{
            self._assetData = .init(wrappedValue: info)
        }
        self.onClose = onClose
        self.size = size
        self._NewsAPI = .init(wrappedValue: .init(currency: [info?.symbol ?? name ?? "BTC"], sources: ["news"], type: .Chronological, limit: 10))
        self._TwitterAPI = .init(wrappedValue: .init(currency: [info?.symbol ?? name ?? "BTC"], sources: ["twitter","reddit"], type: .Chronological, limit: 10))
        self.asset_info = AssetAPI.shared(currency: info?.symbol ?? name ?? "BTC")
    }
    
    
    var currency:CoinGeckoAsset?{
        return self.context.selectedCurrency
    }
    
    func onAppear(){
        if self.TwitterAPI.FeedData.isEmpty{
            self.TwitterAPI.getAssetInfo()
        }
        
        if self.TAPI.transactions.isEmpty{
            self.TAPI.loadTransaction()
        }
        
        if self.NewsAPI.FeedData.isEmpty{
            self.NewsAPI.getAssetInfo()
        }
        
        if self.assetData.isEmpty{
            self.getAssetInfo()
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
        print("(DEBUG) Fetching Data for asset")
        self.asset_info.getUpdateAssetInfo(completion: self.onReceiveNewAssetInfo(asset:))
    }

    func onReceiveNewAssetInfo(asset:AssetData?){
        guard let data = asset else {return}
        DispatchQueue.main.async {
            self.assetData = data
            print("(DEBUG): Updated the Asset Data!")
        }
    }
    
    func onReceiveNewAssetInfo(asset:AssetData?,fn:() -> Void){
        guard let data = asset else {return}
            self.assetData = data
            fn()
//            self.refresh = false
            print("(DEBUG): Updated the Asset Data!")
    }
    
    
    func getAssetInfo(fn: @escaping () -> Void){
        print("(DEBUG) Fetching Data for asset")
        self.asset_info.getUpdateAssetInfo { data in
            self.onReceiveNewAssetInfo(asset: data,fn: fn)
        }
    }
    
    
    func reloadNewsFeed(idx:Int){
        if idx == self.NewsAPI.FeedData.count - 5{
            print("(DEBUG) Fetching more feedData")
            self.NewsAPI.getNextPage()
        }
    }
    
    
    func reloadAssetFeed(idx:Int){
        if idx == self.TwitterAPI.FeedData.count - 5{
            print("(DEBUG) Fetching more feedData")
            self.TwitterAPI.getNextPage()
        }
    }
    
    
    func feedView(w:CGFloat) -> some View{
        
        LazyScrollView(data: self.TwitterAPI.FeedData.compactMap({$0 as Any})) { data in
            if let data = data as? AssetNewsData{
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
            }
        } reload: {
            self.TwitterAPI.getNextPage()
        }
    }
    
    func newsView(w:CGFloat) -> some View{
        LazyScrollView(data: self.NewsAPI.FeedData.compactMap({$0 as Any})) { data in
            if let news = data as? AssetNewsData{
                NewsStandCard(news: news,size: .init(width: w, height: 150))
            }
        } reload: {
            self.NewsAPI.getNextPage()
        }
    }
    
    var txnsForAsset:[Transaction]{
        let symbol = (self.currency?.symbol?.uppercased() ?? "BTC").lowercased()
        return self.TAPI.transactions.filter({$0.symbol == symbol && ($0.type == "buy" || $0.type == "sell")})
    }

    @ViewBuilder var mainView:some View{
        if self.showSection == .none{
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: "\(self.currency?.symbol?.uppercased() ?? "BTC")", width: totalWidth, onClose: self.onClose) { w in
                    let size:CGSize = .init(width: w, height: totalHeight * 0.3)
                    CurrencyDetailView(info: assetData, size: size, asset_feed: $TwitterAPI.FeedData, news: $NewsAPI.FeedData, txns: $TAPI.transactions, showSection: $showSection, onClose: self.onClose)
                }.refreshableView(width: size.width,hasToRender:self.context.selectedCurrency != nil) { fun in
//                    self.getAssetInfo(fn: fun)
                    self.context.selectedCurrency?.updateData()
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
                TransactionDetailsView(txns: self.txnsForAsset,currency:self.assetData.symbol ?? "LTC", currencyCurrentPrice: self.assetData.open ?? 0.0,width: w)
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
