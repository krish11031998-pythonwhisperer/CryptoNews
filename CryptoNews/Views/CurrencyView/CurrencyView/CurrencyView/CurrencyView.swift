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

enum CurrencyViewSection:String{
    case news = "News"
    case txns = "Transactions"
    case feed = "Tweets"
    case none = "None"
    case reddit = "Reddit"
    case videos = "Videos"
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
        self._coinAPI = .init(wrappedValue: .init(crypto: asset.CoinData.id ?? "",name:asset.CoinData.Name))
    }
    
      
    
    func onAppear(){
        if self.assetData.coin == nil{
            self.coinAPI.getCoinData()
            self.loading.toggle()
        }else if self.assetData.coin != nil,let name = self.assetData.coin?.MetaData.Name.lowercased(){
            self.loading.toggle()
            CrybseCoinPriceAPI.shared.refreshLatestPrices(asset: name, interval: "m1") { price in
                guard let latestPrice = price.last else {return}
                setWithAnimation {
                    self.assetData.coin?.prices?.append(latestPrice)
                    self.loading.toggle()
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
    
    
    var tweets:[CrybseTweet]?{
        return self.coinAPI.coinData?.Tweets
    }
    
    var news:[CrybseNews]?{
        return self.coinAPI.coinData?.News
    }
    
    
    @ViewBuilder func feedView(w:CGFloat) -> some View{
        if let feed = self.tweets{
            ForEach(Array(feed.enumerated()),id:\.offset) { _data in
                if let data = _data.element as? CrybseTweet{
                    PostCard(cardType: .Tweet, data: data, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
                }
            }
            .onPreferenceChange(RefreshPreference.self) { reload in
            }
        }else if self.coinAPI.loading{
            ProgressView().frame(width: w, alignment: .center)
        }else{
            MainText(content: "No Feed", fontSize: 15)
            Color.clear.frame(width: w, height: 0, alignment: .center)
        }
        
    }
    
    @ViewBuilder func redditView(w:CGFloat) -> some View{
        if let reddit = self.assetData.coin?.reddit{
            LazyScrollView(data: reddit, embedScrollView: false, stopLoading: true) { data in
                if let redditData = data as? CrybseRedditData{
                    RedditPostCard(width: w, redditPost: redditData)
                }
            }
        }else if self.coinAPI.loading{
            ProgressView().frame(width: w, alignment: .center)
        }else{
            MainText(content: "No Reddit", fontSize: 15)
            Color.clear.frame(width: w, height: 0, alignment: .center)
        }
    }
    
    @ViewBuilder func videoView(w:CGFloat) -> some View{
        if let youtube = self.assetData.coin?.youtube{
            LazyScrollView(data: youtube, embedScrollView: false, stopLoading: true) { data in
                if let videoData = data as? CrybseVideoData{
                    VideoCard(data: videoData, size: .init(width: w, height: totalHeight * 0.3))
                }
            }
        }else if self.coinAPI.loading{
            ProgressView().frame(width: w, alignment: .center)
        }else{
            MainText(content: "No Videos", fontSize: 15)
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
            MainText(content: "No News", fontSize: 15)
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
        CurrencyDetailView(assetData: assetData, size: .init(width: w, height: totalHeight * 0.3),onClose:self.onClose)
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
            self.innerView(w: totalWidth - 10)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder var diff_Views:some View{
        if self.showSection != .none{
            HoverView(heading: self.showSection.rawValue, onClose: self.onCloseSection) { w in
                switch(self.showSection){
                case .feed:
                    self.feedView(w: w)
                case .txns:
                    TransactionDetailsView(txns: self.txnsForAsset,currency:self.assetData.Currency, currencyCurrentPrice: self.assetData.CoinData.Price,width: w)
                case .news:
                    self.newsView(w: w)
                case .reddit:
                    self.redditView(w: w)
                case .videos:
                    self.videoView(w: w)
                default:
                    Color.clear
                }
            }
        }
        
    }
    
    func onDisappear(){
        guard let safeURL = self.coinAPI.request?.url,let _ = self.coinAPI.coinData,let coinData = self.assetData.coin else {return}
        let coinResponse = CrybseCoinDataResponse(data: coinData, success: true)
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
                self.diff_Views
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(self.coinAPI.$coinData, perform: self.onReceiveCoinData(_:))
        .onDisappear(perform: self.onDisappear)
    }
}

