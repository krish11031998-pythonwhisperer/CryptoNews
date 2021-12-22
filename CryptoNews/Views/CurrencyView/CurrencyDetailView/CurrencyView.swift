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
//    @StateObject var coinAPI:CoinRankCoinsAPI = .init()
    var onClose:(()->Void)?
    @State var coinAPI:CoinRankCoinAPI
    @State var currency:CoinData = .init()
    var size:CGSize = .init()
    @StateObject var asset_feed:FeedAPI
    var asset_info:AssetAPI
    @State var showSection:CurrencyViewSection = .none
    @StateObject var NAPI:FeedAPI
    @State var refresh:Bool = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(
        name:String? = nil,
        info:CoinData? = nil,
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
        self._coinAPI = .init(initialValue: .init(coin: info?.uuid ?? "", timePeriod: "24h"))
    }
    
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            if self.coinAPI.coin == nil{
                self.coinAPI.getCoin()
            }
            
            if self.asset_feed.FeedData.isEmpty{
                self.asset_feed.getAssetInfo()
            }
            
            if self.NAPI.FeedData.isEmpty{
                self.NAPI.getAssetInfo()
            }
        }
    }
    
    var transactions:[Transaction]{
        guard let sym = self.currency.symbol else {return []}
        return self.context.balanceForCurrency(asset: sym)
    }
    
    func loadTxns(){
        if let uid = self.context.user.user?.uid{
            self.context.transactionAPI.loadTransaction(uuid: uid)
        }
    }
        
    func onCloseSection(){
        if self.showSection != .none{
            withAnimation(.easeInOut) {
                self.showSection = .none
            }
        }
    }
    
    
    func onReceiveNewCoin(_ coin:CoinData?){
        DispatchQueue.main.async {
            if let newCoin = coin{
                self.currency.description = newCoin.description
                self.currency.links = newCoin.links
                self.currency.supply = newCoin.supply
                self.currency.allTimeHigh = newCoin.allTimeHigh
            }
            if self.refresh{
                self.refresh.toggle()
            }
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
        
        LazyScrollView(data: self.asset_feed.FeedData.compactMap({$0 as Any}),embedScrollView: false) { data in
            if let data = data as? AssetNewsData{
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
            }
        }
        .onPreferenceChange(RefreshPreference.self) { reload in
            if reload{
                self.asset_feed.getNextPage()
            }
        }
    }
    
    func newsView(w:CGFloat) -> some View{
        LazyScrollView(data: self.NAPI.FeedData.compactMap({$0 as Any}),embedScrollView: false) { data in
            if let news = data as? AssetNewsData{
                NewsStandCard(news: news,size: .init(width: w, height: CardSize.slender.height * 0.5))
            }
        }
        .onPreferenceChange(RefreshPreference.self) { reload in
            if reload{
                self.NAPI.getNextPage()
            }
        }
    }
    
    var txnsForAsset:[Transaction]{
        return self.transactions.filter({($0.type == "buy" || $0.type == "sell")})
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
        return CurrencyDetailView(info: $currency, size: size, asset_feed: asset_feed.FeedData, news: NAPI.FeedData, txns:self.transactions, showSection: $showSection, onClose: self.onClose)
    }
    
    var currencyHeading:String{
        return "\(currency.symbol ?? "BTC")"
    }
    
    @ViewBuilder var mainView:some View{
        if self.showSection == .none{
            
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: self.currencyHeading, width: totalWidth, onClose: self.onClose, rightView: self.rightSideView, innerView: self.innerView(w:))
                    .refreshableView(refreshing: $refresh,width: size.width,hasToRender:self.context.selectedCurrency != nil)
                    .onChange(of: self.refresh) { refresh in
                        if self.refresh{
                            self.coinAPI.refreshCoin()
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
                TransactionDetailsView(txns: self.txnsForAsset,currency:self.currency.symbol ?? "LTC", currencyCurrentPrice: self.currency.Price,width: w)
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
        .onReceive(self.coinAPI.$coin,perform: self.onReceiveNewCoin(_:))
    }
}

struct CurrencyViewTester:PreviewProvider{
    static var context:ContextData = .init()
    
    static var previews: some View{
        CurrencyView(name: "MANA")
            .environmentObject(CurrencyViewTester.context)
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
