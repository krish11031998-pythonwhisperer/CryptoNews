//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct ShowSectionPreferenceKey:PreferenceKey{
    static var defaultValue: CurrencyViewSection = .none
    
    static func reduce(value: inout CurrencyViewSection, nextValue: () -> CurrencyViewSection) {
        value = nextValue()
    }
}

struct CurrencyDetailView: View {
    @EnvironmentObject var context:ContextData
    @Namespace var animation
    @State var showMoreSection:CurrencyViewSection = .none
    @StateObject var timeSeriesAPI:CrybseTimeseriesPriceAPI
    @ObservedObject var assetData: CrybseAsset
    var size:CGSize = .init()
    var onClose: (() -> Void)?
    @State var timeCounter:Int = 0
    @State var refresh:Bool = false
    @State var choosen:Int = -1
    @State var choosenTimeInterval:String = "1hr"
    init(
        assetData:CrybseAsset,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.15),
        onClose: (() -> Void)? = nil
    )
    {
             
        self.assetData = assetData
        self._timeSeriesAPI = .init(wrappedValue: .init(currency: assetData.currency, limit: 1, fiat: "USD"))
        self.size = size
        self.onClose = onClose
    }
    
    
    var body:some View{
        self.mainView
            .preference(key: ShowSectionPreferenceKey.self, value: self.showMoreSection)
            .onReceive(self.timeSeriesAPI.$timeseriesData, perform: self.onReceiveNewTimeseriesData(timeSeries:))
            .onChange(of: self.refresh) { newValue in
                if newValue{
                    self.getLatestPrice()
                }
            }            
    }
}

extension CurrencyDetailView{
        
    @ViewBuilder var mainView:some View{
        StylisticHeaderView(heading: self.assetData.Currency, subHeading: self.assetData.Price?.ToMoney() ?? "$0",baseNavBarHeight: totalHeight * 0.6,minimumNavBarHeight: totalHeight * 0.125, headerView: { size in
            CurrencyPriceSummaryView(asset: self.assetData, width: size.width, height: size.height, choosenPrice: self.$choosen, choosenInterval: self.$choosenTimeInterval, refresh: $refresh)
        }, innerView: {
            Container(width:self.size.width,ignoreSides:true,lazyLoad: true){_ in
                self.transactionHistoryView
                self.CurrencySummary
                self.infoSection
                self.SentimentSection
                self.EventSection
                self.NewsSection
                self.TweetSection
//                self.eventsView
//                self.newsView
//                self.socialCenter
            }.padding(.vertical,50)
        }, bg: Color.AppBGColor.anyViewWrapper()) {
            self.onClose?()
            
        }
    }
    
    @ViewBuilder var eventsView:some View{
        if let safeEvents = self.socialData?.events{
            Container(width:self.size.width,verticalPadding:0){ inner_w in
                SocialSection(data: safeEvents.count > 5 ? Array(safeEvents[0...4]) : safeEvents, section: .Events, viewSection: .constant(.Events), width: inner_w) { size, data in
                    if let safeEvent = data as? CrybseEventData{
                        EventSnapshot(event: safeEvent, width: size.width)
                    }
                }
                MainText(content: "More", fontSize: 12, color: SectionStylings.events.color, fontWeight: .medium)
                    .textBubble(color: SectionStylings.events.color, clipping: .roundClipping, verticalPadding: 5, horizontalPadding: 10)
                    .frame(width: inner_w, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder var newsView:some View{
        if let safeNews = self.socialData?.news{
            Container(width:self.size.width,verticalPadding:0){ inner_w in
                SocialSection(data: safeNews.count > 5 ? Array(safeNews[0...4]) : safeNews, section: .News, viewSection: .constant(.News), width: inner_w) { size, data in
                    if let safeNews = data as? CrybseNews{
                        NewsSnapshot(news: safeNews, width: size.width)
                    }
                }
                MainText(content: "More", fontSize: 12, color: SectionStylings.news.color, fontWeight: .medium)
                    .textBubble(color: SectionStylings.news.color, clipping: .roundClipping, verticalPadding: 5, horizontalPadding: 10)
                    .frame(width: inner_w, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder var youtubeView:some View{
        if let safeYoutube = self.socialData?.youtube{
            SocialSection(data: safeYoutube.count > 5 ? Array(safeYoutube[0...4]) : safeYoutube, section: .Youtube, viewSection: .constant(.Youtube), width: self.size.width) { size, data in
                Color.clear
            }
        }
    }
    
    
    var socialCenter:some View{
        SocialCenterView(
            tweets: self.socialData?.tweets,
            reddits: self.socialData?.reddit,
            width: self.size.width,
            height: totalHeight * 0.35
        )
    }
    
    var headingFontSize:CGFloat{
        return 20
    }

    var socialData:CrybseCoinSocialData?{
        return self.assetData.coin
    }
    
    func getLatestPrice(){
        guard let name = self.assetData.coin?.MetaData.Name.lowercased() else {
            print("(Error) Invalid CoinName !")
            return
        }
        
        CrybseCoinPriceAPI.shared.refreshLatestPrices(asset: name, interval: "m5") { prices in
            setWithAnimation {
                if let latestPrice = prices.last{
                    self.assetData.coin?.prices?.append(latestPrice)
                }
                self.refresh.toggle()
            }
        }
    }

    @ViewBuilder var NewsSection:some View{
        if let safeNews = self.socialData?.news{
            let news = safeNews.count > 3 ? Array(safeNews[0...2]) : safeNews
            Container(heading: "Trending News", headingColor: .white, headingDivider: false, headingSize: 30, width: self.size.width, lazyLoad: true,rightView: {
                MainText(content: "View More", fontSize: 15, color: .white, fontWeight: .medium)
                    .textBubble(color: .white, clipping: .roundClipping, verticalPadding: 6.5, horizontalPadding: 10)
                    .anyViewWrapper()
            }) { w in
                ForEach(Array(news.enumerated()), id: \.offset) { _news in
                    if _news.offset != 0{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: w,height: 1.5, alignment: .center)
                    }
                    NewsSnapshot(news: _news.element, width: w)
                        .buttonify {
                            if self.context.selectedLink?.absoluteString != _news.element.NewsURL{
                                setWithAnimation {
                                    self.context.selectedLink = URL(string: _news.element.NewsURL)
                                }
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder var TweetSection:some View{
        if let safeTweet = self.socialData?.tweets{
            let tweets = safeTweet.count > 5 ? Array(safeTweet[0...5]) : safeTweet
            Container(heading: "Top Tweets", headingColor: .white, headingDivider: false, headingSize: 30, width: self.size.width,ignoreSides: true, lazyLoad: false,rightView: {
                MainText(content: "View More", fontSize: 15, color: .white, fontWeight: .medium)
                    .textBubble(color: .white, clipping: .roundClipping, verticalPadding: 6.5, horizontalPadding: 10)
                    .anyViewWrapper()
            }){ w in
                ZoomInScrollView(data: tweets, centralizeStart: true, lazyLoad: false, size: .init(width: w * 0.8, height: totalHeight * 0.3), selectedCardSize: .init(width: w * 0.8, height: totalHeight * 0.3)) { data, size, _ in
                    if let safeTweet = data as? CrybseTweet{
                        TweetSnapshot(tweet: safeTweet, width: size.width, height: size.height)
                            .frame(width: size.width, height: size.height, alignment: .topLeading)
                            .basicCard(size: size)
                            .borderCard(color: .white, clipping: .roundClipping)
                            .slideZoomInOut(cardSize: size)
                            .buttonify {
                                if self.context.selectedTweet?.id != safeTweet.id{
                                    setWithAnimation {
                                        self.context.selectedTweet = safeTweet
                                    }
                                }
                            }
                    }
                }
                
            }
        }
    }
    
    @ViewBuilder var SentimentSection:some View{
        if let safeSentiment = self.socialData?.sentiment{
            Container(heading: "Sentiments", headingColor: .white, headingDivider: false, headingSize: 30, width: self.size.width,onClose: nil){w in
                SentimentsSnapshot(sentiment: safeSentiment, width: w)
                    .basicCard()
                    .borderCard(color: .white, clipping: .roundClipping)
                    .slideZoomInOut(cardSize: size)
            }
            
            
        }
    }
    
    @ViewBuilder var EventSection:some View{
        if let safeEvent = self.socialData?.events{
            Container(heading: "Events", headingColor: .white, headingDivider: false, headingSize: 30, width: self.size.width,onClose: nil) {
                MainText(content: "View More", fontSize: 15, color: .white, fontWeight: .medium)
                    .textBubble(color: .white, clipping: .roundClipping, verticalPadding: 6.5, horizontalPadding: 10)
                    .anyViewWrapper()
            } innerView: { w in
                ZoomInScrollView(data: safeEvent,centralizeStart: true, size: .init(width: w * 0.6, height: totalHeight * 0.35), selectedCardSize: .init(width: w * 0.6, height: totalHeight * 0.35)){ data,size,_ in
                    
                    if let safeEvent = data as? CrybseEventData{
                        EventSnapshot(event: safeEvent, width: size.width, height: size.height)
                            .frame(width: size.width, height: size.height, alignment: .topLeading)
                            .basicCard(size: size)
                            .borderCard(color: .white, clipping: .roundClipping)
                            .slideZoomInOut(cardSize: size)
                    }
                    
                }
            }

            
            
        }
    }
    
    var choosenPriceData:CrybseCoinPrice{
        if self.choosen != -1{
            let offset = self.Prices.count - self.timeSpan
            let idx = offset + (self.choosen == -1 ? 0 : self.choosen)
            return self.Prices[idx]
        }
        
        return self.Prices.last ?? .init()
    }
    
    var News:[CrybseNews]{
        print("(DEBUG) News : ",self.socialData?.News)
        return self.socialData?.News ?? []
    }
    
    var Reddit:CrybseRedditPosts{
        return self.socialData?.RedditPosts ?? []
    }
    
    var Videos:CrybseVideosData{
        return self.socialData?.Videos ?? []
    }
    
    var Tweets:[CrybseTweet]{
        return self.socialData?.Tweets ?? []
    }
    
    var txns:[Transaction]{
        return self.assetData.txns ?? []
    }
    
    var coinTotal:Float{
        return self.assetData.coinTotal ?? 0
    }

    var valueTotal:Float{
        return self.coinTotal * self.price
    }
    
      
    var profit:Float{
        if self.choosen != -1,let selectedPrice = self.Prices[self.choosen].price{
            return self.assetData.txns?.map({$0.Asset_Quantity * (selectedPrice - $0.Asset_Spot_Price)}).reduce(0, {$0 == 0 ? $1 : $0 + $1}) ?? self.assetData.Profit
        }
        return self.assetData.Profit
    }
    
    var txnForAssetPortfolioData:[PortfolioData]{
        return self.txns.compactMap({$0.parseToPortfolioData()})
    }
    
    var CurrencySummary:some View{
        Container(heading: "Statistics",headingSize: headingFontSize, width: self.size.width, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
            if let coinMetaData = self.socialData?.MetaData{
                CurrencySummaryView(currency: coinMetaData, size: .init(width: w, height: self.size.height))
            }else{
                Color.clear.frame(width: w, height: self.size.height - 15, alignment: .center)
            }
        }
        .basicCard(size: .zero)
    }
    
    
    func handleAddTxn(){
        if !self.context.addTxn{
            self.context.addTxn.toggle()
        }
        if self.context.selectedSymbol != self.assetData.Currency{
            self.context.selectedSymbol = self.assetData.Currency
        }
    }
    
    func viewPortfolio(){
        withAnimation(.easeInOut) {
            self.showMoreSection = .txns
        }
    }
    
    @ViewBuilder var transactionHistoryView:some View{
        if !self.txns.isEmpty{
            MarkerMainView(data: .init(crypto_coins: Double(self.coinTotal), value_usd: self.valueTotal,profit: self.profit, fee: 1.36, totalfee: 0.0, totalBuys: 1,currentPrice: self.price,txns: self.txnForAssetPortfolioData), size: .init(width: size.width, height: size.height * 1.5))
            HStack(alignment: .center, spacing: 10) {
                TabButton(width: self.size.width * 0.5 - 10, height: 50, title: "View Portfolio", textColor: .white,action: self.viewPortfolio)
                TabButton(width: self.size.width * 0.5 - 10, height: 50, title: "Add a New Txn", textColor: .white,action: self.handleAddTxn)
            }.frame(width: self.size.width, alignment: .center)
        }else{
            TabButton(width: self.size.width, height: 50, title: "Add a New Txn", textColor: .white,action: self.handleAddTxn)
        }
    }
    
    @ViewBuilder var infoSection:some View{
        if let description = self.socialData?.MetaData.Description,description != ""{
            Container(width:self.size.width - 30){_ in
                MainText(content: description, fontSize: 15, color: .white, fontWeight: .medium)
            }.borderCard()
                .padding(.horizontal)
                .frame(width: self.size.width, alignment: .center)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
       
    }
    

    var timeSpan:Int{
        let hr = 12
        if self.choosenTimeInterval == "3hr"{
            return hr * 3
        }else if self.choosenTimeInterval == "6hr"{
            return hr * 6
        }else if self.choosenTimeInterval == "24hr"{
            return hr * 24
        }
        return hr
    }

    var Prices:CrybseCoinPrices{
        guard let prices = self.assetData.coin?.prices else {return []}
        let length = prices.count
        return length > self.timeSpan ? Array(prices[(length - self.timeSpan)...]) : prices
    }
    
    var curveChart:some View{
        return ZStack(alignment: .center){
            if !self.Prices.isEmpty{
                CurveChart(data: self.Prices.compactMap({$0.price}),choosen: $choosen,interactions: true,size: self.size, bg: .clear,chartShade: true)
            }else{
                MainText(content: "No Time Series Data", fontSize: 20, color: .white, fontWeight: .bold)
                    .frame(width: self.size.width, height: self.size.height, alignment: .center)
            }
        }
    }
    
    
    var price:Float{
        if !self.Prices.isEmpty{
            if self.choosen > 0 && self.choosen < self.Prices.count{
                return self.Prices[self.choosen].Price
            }else if let latestPrice = self.Prices.last{
                return latestPrice.Price
            }
        }
        return self.socialData?.MetaData.Price ?? 0
    }
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 17.5) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: heading_size, color: .white, fontWeight: .semibold)
            MainText(content: info, fontSize: info_size, color: .white, fontWeight: .regular)
        }
    }
    
    func onReceiveNewTimeseriesData(timeSeries:Array<CryptoCoinOHLCVPoint>?){
        setWithAnimation {
            self.assetData.updatePriceWithLatestTimeSeriesPrice(timeSeries: timeSeries)
            self.timeCounter = 0
        }
    }
    
    func social_media_size ( _ w:CGFloat, _ h:CGFloat) -> CGSize{
        var min = min(w,h)
        min -= min == 0 ? 0 : 35
        return CGSize(width: min , height: min)
    }
}


struct CurrencyViewPreview:PreviewProvider{
    
    static func loadCoinData() -> CrybseAsset?{
        guard let safeData = readJsonFile(forName: "btcCoinData"),let coinSocialData = CrybseCoinSocialData.parseCoinDataFromData(data: safeData) else {return nil}
        let asset = CrybseAsset(currency: "BTC")
        asset.coin = coinSocialData
        return asset
    }
    
    static var previews: some View{
        if let safeAsset = CurrencyViewPreview.loadCoinData(){
                CurrencyDetailView(assetData: safeAsset)
            
            
        }else{
            ProgressView()
        }
        
    }
}
