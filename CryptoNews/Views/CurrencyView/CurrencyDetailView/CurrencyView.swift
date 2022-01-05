//
//  CurrencyView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/10/2021.
//

import Foundation
import Combine
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
    @StateObject var coinAPI:CrybseCoinSocialAPI
    @State var assetData:CrybseAsset?
    var size:CGSize = .init()
    @State var showSection:CurrencyViewSection = .none
    @State var refresh:Bool = false
    @State var timeCounter:Int = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(
        name:String? = nil,
        info:CrybseAsset? = nil,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        self._assetData = .init(initialValue: info)
        self.onClose = onClose
        self.size = size
        self._coinAPI = .init(wrappedValue: .init(coinUID: info?.coinData?.uuid ?? "", fiat: "USD", crypto: info?.coinData?.Symbol ?? ""))
    }
    
    
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            withAnimation(.easeInOut) {
                if self.coinAPI.coinData == nil{
                    self.coinAPI.getCoinData()
                }
            }
        }
    }
    
    
    func onReceiveCoinData(coinData: CrybseCoinSocialData?){
        guard let coinData = coinData else {
            return
        }
        self.assetData?.coin = coinData
    }
    
    var transactions:[Transaction]{
        guard let txns = self.assetData?.txns else {return []}
        return txns
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
    
    
    var tweets:[AssetNewsData]?{
        return self.coinAPI.coinData?.Tweets
    }
    
    var news:[CryptoNews]?{
        return self.coinAPI.coinData?.News
    }
    
    
    @ViewBuilder func feedView(w:CGFloat) -> some View{
        if let feed = self.tweets{
            LazyScrollView(data: feed.compactMap({$0 as Any}),embedScrollView: false) { data in
                if let data = data as? AssetNewsData{
                    let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                    PostCard(cardType: cardType, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
                }
            }
            .onPreferenceChange(RefreshPreference.self) { reload in
//                if reload{
//                    self.asset_feed.getNextPage()
//                }
            }
        }else if self.coinAPI.loading{
            ProgressView().frame(width: w, alignment: .center)
        }else{
            Color.clear.frame(width: w, height: 0, alignment: .center)
        }
        
    }
    
    @ViewBuilder func newsView(w:CGFloat) -> some View{
        if let news = self.news{
            LazyScrollView(data: news,embedScrollView: false) { data in
                NewsStandCard(news: data,size: .init(width: w, height: CardSize.slender.height * 0.5))
            }
            .onPreferenceChange(RefreshPreference.self) { reload in
//                if reload{
//                    self.NAPI.getNextPage()
//                }
            }
        }else if self.coinAPI.loading{
            ProgressView().frame(width: w, alignment: .center)
        }else{
            Color.clear.frame(width: w, height: 0, alignment: .center)
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
                if let sym = self.assetData?.currency, let included = self.context.user.user?.watching.contains(sym), !included{
                    self.context.user.user?.watching.append(sym)
                    self.context.user.updateUser()
                }
            }
        })
    }

    func innerView(w:CGFloat) -> some View{
        let size:CGSize = .init(width: w, height: totalHeight * 0.3)
        return CurrencyDetailView(assetData: $assetData, size: .init(width: w, height: totalHeight * 0.3), showSection: $showSection, onClose: self.onClose)
    }
    
    var currencyHeading:String{
        return "\(assetData?.currency ?? "BTC")"
    }
    
    @ViewBuilder var mainView:some View{
        if self.showSection == .none{
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: self.currencyHeading, width: totalWidth, onClose: self.onClose, rightView: self.rightSideView, innerView: self.innerView(w:))
                    .refreshableView(refreshing: $refresh,width: size.width,hasToRender:self.context.selectedCurrency != nil)
                    .onChange(of: self.refresh) { refresh in}
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
                TransactionDetailsView(txns: self.txnsForAsset,currency:self.assetData?.currency ?? "LTC", currencyCurrentPrice: self.assetData?.coinData?.Price ?? 0,width: w)
            }
        }
        if self.showSection == .news{
            HoverView(heading: "News", onClose: self.onCloseSection) { w in
                self.newsView(w: w)
            }
        }
    }
    
    func onReceiveTimer(){
        if self.timeCounter < 60{
            self.timeCounter += 5
        }else if self.timeCounter >= 60 && !CrybseTimeseriesPriceAPI.shared.loading{
            if let sym = self.assetData?.Currency{
                CrybseTimeseriesPriceAPI.shared.getPrice(currency: sym, limit: 1) { data in
                    if let cryptoData = CrybseTimeseriesPriceAPI.parseData(data: data){
//                        setWithAnimation {
                            self.assetData?.coin?.TimeseriesData?.append(contentsOf: cryptoData)
//                        }
//                        if CrybseTimeseriesPriceAPI.shared.loading{
//                            CrybseTimeseriesPriceAPI.shared.loading.toggle()
//                        }
//                        self.timeCounter = 0
                    }
                    DispatchQueue.main.async {
                        if CrybseTimeseriesPriceAPI.shared.loading{
                            CrybseTimeseriesPriceAPI.shared.loading.toggle()
                        }
                        self.timeCounter = 0
                    }
                }
            }
        }
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            if self.assetData?.coin != nil{
                self.mainView
            }else if self.coinAPI.loading{
                ProgressView().frame(width: totalWidth, alignment: .center)
            }
            self.diff_Views
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(self.timer, perform: { _ in
            self.onReceiveTimer()
        })
        .onReceive(self.coinAPI.$coinData) {coinData in
            self.onReceiveCoinData(coinData: coinData)
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
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
