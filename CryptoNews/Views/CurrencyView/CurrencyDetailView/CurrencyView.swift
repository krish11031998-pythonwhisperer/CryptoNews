//
//  CurrencyView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/10/2021.
//

import Foundation
import SwiftUI



struct CurrencyView:View{

    var onClose:(()->Void)?
    @State var currency:AssetData
    var size:CGSize = .init()
    @StateObject var asset_feed:FeedAPI
    var asset_info:AssetAPI
    @State var showMoreView:Bool = false
    @StateObject var TAPI:TransactionAPI = .init()
    
    
    init(
//        heading:String,
        info:AssetData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        self._currency = .init(wrappedValue: info)
//        self.heading = heading
        self.onClose = onClose
        self.size = size
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
    }
    
    
    func onCloseFeed(){
        if self.showMoreView{
            withAnimation(.easeInOut) {
                self.showMoreView = false
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
    
    func reload(idx:Int){
        if idx == self.asset_feed.FeedData.count - 5{
            print("(DEBUG) Fetching more feedData")
            self.asset_feed.getNextPage()
        }
    }
    
    func reload(){
        print("(DEBUG) Fetching more feedData")
        self.asset_feed.getNextPage()
    }
    
    func feedView(w:CGFloat) -> some View{
        ForEach(Array(self.asset_feed.FeedData.enumerated()),id:\.offset){ _data in
            let data = _data.element
            let idx = _data.offset
            let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
            PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
                .onAppear {
                    self.reload(idx: idx)
                }
                .padding(.bottom,idx == self.asset_feed.FeedData.count - 1 ? 100 : 0)
        }
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            if !self.showMoreView{
                ScrollView(.vertical, showsIndicators: false) {
                    Container(heading: "\(currency.symbol ?? "BTC")", width: totalWidth,refresh: true, onClose: self.onClose) { w in
                        CurrencyDetailView(info: $currency, size: .init(width: w, height: totalHeight * 0.3), asset_feed: $asset_feed.FeedData, showMoreView: $showMoreView, txns: $TAPI.transactions, reloadAsset: self.getAssetInfo, reloadFeed: self.reload, onClose: self.onClose)
                    }.padding(.top,50)
                }
            }
            if self.showMoreView{
                HoverView(heading: "Feed", onClose: self.onCloseFeed) {w in
                    LazyVStack(alignment: .leading, spacing: 10) {
                        self.feedView(w: w)
                    }
                }
            }
        }.onAppear(perform: self.onAppear)
        
        
    }
    
    
}
