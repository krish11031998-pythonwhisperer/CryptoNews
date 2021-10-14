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

    var onClose:(()->Void)?
    @State var currency:AssetData
    var size:CGSize = .init()
    @StateObject var asset_feed:FeedAPI
    var asset_info:AssetAPI
    @State var showSection:CurrencyViewSection = .none
    @StateObject var TAPI:TransactionAPI = .init()
    @StateObject var NAPI:FeedAPI
    
    
    init(
        info:AssetData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        self._currency = .init(wrappedValue: info)
        self.onClose = onClose
        self.size = size
        self._NAPI = .init(wrappedValue: .init(currency: [info.symbol ?? "BTC"], sources: ["news"], type: .Chronological, limit: 10))
        self._asset_feed = .init(wrappedValue: .init(currency: [info.symbol ?? "BTC"], sources: ["twitter","reddit"], type: .Chronological, limit: 10))
        self.asset_info = AssetAPI.shared(currency: info.symbol ?? "BTC")
    }
    
    func onAppear(){
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
        print("(DEBUG) Fetching Data for asset")
        self.asset_info.getUpdateAssetInfo(completion: self.onReceiveNewAssetInfo(asset:))
    }
    
    func onReceiveNewAssetInfo(asset:AssetData?){
        guard let data = asset else {return}
        DispatchQueue.main.async {
            self.currency = data
            print("(DEBUG): Updated the Asset Data!")
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
    
    func reloadAssetFeed(){
        print("(DEBUG) Fetching more feedData")
        self.asset_feed.getNextPage()
    }
    
    func feedView(w:CGFloat) -> some View{
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(Array(self.asset_feed.FeedData.enumerated()),id:\.offset){ _data in
                let data = _data.element
                let idx = _data.offset
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
                    .onAppear {
                        self.reloadAssetFeed(idx: idx)
                    }
                    .padding(.bottom,idx == self.asset_feed.FeedData.count - 1 ? 100 : 0)
            }
        }
    }
    
    func newsView(w:CGFloat) -> some View{
        return LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(Array(self.NAPI.FeedData.enumerated()),id: \.offset) { _news in
                let news = _news.element
                let idx = _news.offset
                NewsStandCard(news: news,size: .init(width: w, height: 150))
                    .onAppear{
                        self.reloadNewsFeed(idx: idx)
                    }
            }
        }
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            if self.showSection == .none{
                ScrollView(.vertical, showsIndicators: false) {
                    Container(heading: "\(currency.symbol ?? "BTC")", width: totalWidth,refresh: true, onClose: self.onClose) { w in
                        let size:CGSize = .init(width: w, height: totalHeight * 0.3)
                        CurrencyDetailView(info: $currency, size: size, asset_feed: $asset_feed.FeedData, news: $NAPI.FeedData, txns: $TAPI.transactions, showSection: $showSection, reloadAsset: self.reloadAssetFeed, reloadFeed: self.getAssetInfo, onClose: self.onClose)
                    }.padding(.top,50)
                }
            }
            if self.showSection == .feed{
                HoverView(heading: "Feed", onClose: self.onCloseSection) {w in
                    self.feedView(w: w)
                }
            }
            if self.showSection == .txns{
                HoverView(heading: "Transactions", onClose: self.onCloseSection) { w in
                    TransactionDetailsView(txns: self.TAPI.transactions.filter({$0.symbol == self.currency.symbol?.lowercased() && ($0.type == "buy" || $0.type == "sell")}),width: w)
                }
            }
            if self.showSection == .news{
                HoverView(heading: "News", onClose: self.onCloseSection) { w in
                    self.newsView(w: w)
                }
            }
        }.onAppear(perform: self.onAppear)
        
        
    }
    
    
}
