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
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var context:ContextData
    @StateObject var assetData:CrybseAsset
    @StateObject var coinAPI:CrybseCoinSocialAPI
    @State var displaySection:Bool = false
    var size:CGSize = .init()
    @State var loading:Bool = false
    @State var showSection:CurrencyViewSection = .none
    @State var refresh:Bool = false
    
    init(
        asset:CrybseAsset,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3)
    ){
        self._assetData = .init(wrappedValue: asset)
        self.size = size
        self._coinAPI = .init(wrappedValue: .init(coinUID:asset.CoinData.id ?? "",crypto: asset.CoinData.Symbol.uppercased(),name:asset.CoinData.Name))
    }
    
    
    func onClose(){
        self.presentationMode.wrappedValue.dismiss()
        if self.context.selectedAsset != nil{
            self.context.selectedAsset = nil
        }
    }
    
    func onAppear(){
        if self.assetData.coin == nil{
            self.coinAPI.getCoinData()
            self.loading.toggle()
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
            Container(heading: "Tweets", headingColor: .white, headingDivider: false, headingSize: 30, width: w, lazyLoad: true) {
                self.displaySection = false
                if self.showSection != .none{
                    self.showSection = .none
                }
            } innerView: { w in
                ForEach(Array(feed.enumerated()),id:\.offset) { _tweet in
                    TwitterPostCard(cardType: .Tweet, data: _tweet.element, size: .init(width: w, height: totalHeight * 0.3), font_color: .white, const_size: false)
                }
            }
            .onPreferenceChange(RefreshPreference.self) { reload in
            }
            self.tweetNavLink
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
            Container(heading: "News", headingColor: .white, headingDivider: false, headingSize: 30, width: w, lazyLoad: true) {
                self.displaySection = false
                if self.showSection != .none{
                    self.showSection = .none
                }
            } innerView: { w in
                ForEach(Array(news.enumerated()),id:\.offset) { _news in
                    NewsStandCard(news: _news.element,size: .init(width: w, height: CardSize.slender.height * 0.5))
                }
            }
            .onPreferenceChange(RefreshPreference.self) { reload in
            }
            self.newsNavLink
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

    var currencyHeading:String{
        return "\(assetData.currency ?? "BTC")"
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
    
    @ViewBuilder var tweetNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showTweet) {
            if let selectedTweet = self.context.selectedTweet{
                ScrollView(.vertical, showsIndicators: false) {
                    TweetDetailMainView(tweet: selectedTweet, width: totalWidth)
                }
            }else{
                Color.clear
            }
        }
    }
    
    @ViewBuilder var newsNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showNews) {
            if let selectedNews = self.context.selectedNews{
                ScrollView(.vertical, showsIndicators: false) {
                    NewsDetailView(news: selectedNews, width: totalWidth)
                }
            }else{
                Color.clear
            }
        }
    }
    
    @ViewBuilder var MoreNewsnavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$displaySection){
            ScrollView(.vertical, showsIndicators: false) {
                switch(self.showSection){
                    case .news:
                        self.newsView(w: totalWidth)
                    case .feed:
                        self.feedView(w: totalWidth)
                    case .txns:
                        Container(width:totalWidth){w in
                            TransactionDetailsView(txns: self.txnsForAsset,currency:self.assetData.Currency, currencyCurrentPrice: self.assetData.CoinData.Price,width: w)
                        }
                    default:
                        Color.clear
                }
            }
        }
        
    }
    
    var body:some View{
        ZStack(alignment: .topLeading) {
            if !self.loading{
                CurrencyDetailView(assetData: assetData, size: .init(width: totalWidth - 10, height: totalHeight * 0.3),showSection: $showSection,onClose:self.onClose)
                //NavigationLinks
                if !self.displaySection{
                    self.tweetNavLink
                    self.newsNavLink
                }
                self.MoreNewsnavLink
            }else{
                ProgressView()
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(self.coinAPI.$coinData, perform: self.onReceiveCoinData(_:))
        .onDisappear(perform: self.onDisappear)
        .onChange(of: self.showSection) { newValue in
            if newValue != .none && !self.displaySection{
                self.displaySection = true
            }
        }
    }
}
