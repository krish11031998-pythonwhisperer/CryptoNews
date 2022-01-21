//
//  CurrencyView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/10/2021.
//

import Foundation
import Combine
import SwiftUI

struct AssetPreferenceKey:PreferenceKey{
    static var defaultValue: CrybseAsset = .init(currency: nil)
    
    
    static func reduce(value: inout CrybseAsset, nextValue: () -> CrybseAsset) {
        value = nextValue()
    }
}

enum CurrencyViewSection{
    case news
    case txns
    case feed
    case none
}
struct CurrencyView:View{
    @EnvironmentObject var context:ContextData
    @StateObject var assetData:CrybseAsset
    var onClose:(()->Void)?
    @StateObject var coinAPI:CrybseCoinSocialAPI
    var size:CGSize = .init()
    @State var loading:Bool = false
    @State var showSection:CurrencyViewSection = .none
    @State var refresh:Bool = false
    
    init(
        asset:CrybseAsset,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
        onClose:(() -> Void)? = nil
    ){
        self._assetData = .init(wrappedValue: asset)
        self.onClose = onClose
        self.size = size
        self._coinAPI = .init(wrappedValue: .init(coinUID: asset.coinData?.uuid ?? "", fiat: "USD", crypto: asset.Currency))
    }
    
    
    
    func onAppear(){
        if self.assetData.coin == nil{
            self.coinAPI.getCoinData()
            self.loading.toggle()
        }else if let _ = self.assetData.coin?.TimeseriesData{
            CrybseTimeseriesPriceAPI.shared.getPrice(currency: self.assetData.Currency) { data in
                if let timeData = CrybseTimeseriesPriceAPI.parseData(data: data){
                    setWithAnimation {
                        self.assetData.coin?.TimeseriesData = timeData
                    }
                }
            }
        }
    }
    
    func onReceiveCoinData(_ coinData: CrybseCoinSocialData?){
        guard let coinData = coinData else {
            return
        }
        setWithAnimation {
            self.assetData.coin = coinData
            self.loading.toggle()
        }
    }
    
    var transactions:[Transaction]{
        guard let txns = self.assetData.txns else {return []}
        return txns
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
                if let sym = self.assetData.currency, let included = self.context.user.user?.watching.contains(sym), !included{
                    self.context.user.user?.watching.append(sym)
                    self.context.user.updateUser()
                }
            }
        })
    }

    @ViewBuilder func innerView(w:CGFloat) -> some View{
        let size:CGSize = .init(width: w, height: totalHeight * 0.3)
        CurrencyDetailView(assetData: assetData, size: .init(width: w, height: totalHeight * 0.3))
            .onPreferenceChange(ShowSectionPreferenceKey.self) { showSection in
                setWithAnimation {
                    self.showSection = showSection
                }
            }
    }
    
    var currencyHeading:String{
        return "\(assetData.currency ?? "BTC")"
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
                TransactionDetailsView(txns: self.txnsForAsset,currency:self.assetData.Currency, currencyCurrentPrice: self.assetData.coinData?.Price ?? 0,width: w)
            }
        }
        if self.showSection == .news{
            HoverView(heading: "News", onClose: self.onCloseSection) { w in
                self.newsView(w: w)
            }
        }
    }
    
    func onDisappear(){
        guard let safeURL = self.coinAPI.url,let originalCoinData = self.coinAPI.coinData,let coinData = self.assetData.coin else {return}
        let coinResponse = CrybseCoinSocialDataResponse(data: coinData, success: true)
        let encoder = JSONEncoder()
        do{
            let res = try encoder.encode(coinResponse)
            DataCache.shared[safeURL] = res
            print("(DEBUG) Successfully updated the dataCache for url : ",safeURL.absoluteString)
        }catch{
            print("(DEBUG-Error) Error while trying to encode the coinData : ",error.localizedDescription)
        }
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            if !self.loading {
                self.mainView
            }else{
                ProgressView().frame(width: totalWidth, alignment: .center)
            }
            self.diff_Views
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(self.coinAPI.$coinData, perform: self.onReceiveCoinData(_:))
        .onDisappear(perform: self.onDisappear)
        .preference(key: AssetPreferenceKey.self, value: self.assetData)
    }
}

