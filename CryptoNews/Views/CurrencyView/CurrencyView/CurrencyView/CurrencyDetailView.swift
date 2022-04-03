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
            Container(width:self.size.width,ignoreSides:true){_ in
                self.transactionHistoryView
                self.CurrencySummary
                self.infoSection
                self.feedContainer
                self.newsContainer
                self.redditContainer
            }.padding(.vertical,50)
        }, bg: Color.AppBGColor.anyViewWrapper()) {
//            self.onClose?()
            self.onClose?()
            
        }
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

    
    var choosenPriceData:CrybseCoinPrice{
        if self.choosen != -1{
            let offset = self.Prices.count - self.timeSpan
            let idx = offset + (self.choosen == -1 ? 0 : self.choosen)
            return self.Prices[idx]
        }
        
        return self.Prices.last ?? .init()
    }
    
    var News:[AssetNewsData]{
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
    
    var paginatedViews:some View{
        var tab:[String:AnyView] = [:]
        if !self.Tweets.isEmpty{
            tab["Twitter"] = AnyView(self.feedContainer)
        }
        
        if !self.Reddit.isEmpty{
            tab["Reddit"] = AnyView(self.redditContainer)
        }
        
        if !self.News.isEmpty{
            tab["News"] = AnyView(self.newsContainer)
        }
        
        if !self.Videos.isEmpty{
            tab["Videos"] = AnyView(self.youtubeContainer)
        }
        
        return ButtonScrollView(headerviews: tab, width: self.size.width)
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
        if let _ = self.socialData?.MetaData,let additionalInfo = self.assetData.coin?.additionalInfo{
            Container(heading: "About",headingSize: headingFontSize, width: self.size.width,horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
                MainText(content: "What is \(self.assetData.Currency)", fontSize: 17.5, color: .white, fontWeight: .medium).frame(width: w, alignment: .leading)
                MainText(content: additionalInfo.description ?? "", fontSize: 15, color: .white, fontWeight: .regular).frame(width: w, alignment: .leading)
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
       
    }
    
    
    @ViewBuilder func cardBuilder(width w:CGFloat? = nil ,type:PostCardType,data:Any) -> some View{
        let width = w ?? self.size.width
        switch(type){
            case .Tweet:
                if let post = data as? CrybseTweet{
                    PostCard(cardType: .Tweet, data: post, size: .init(width: width, height: self.size.height),bg: .light, const_size: false)
                }else{
                    Color.clear
                }
                
            case .News:
                NewsStandCard(news: data,size:.init(width: width, height: totalHeight * 0.25))
            case .Reddit:
                if let reddit = data as? CrybseRedditData{
                    RedditPostCard(width: width, redditPost: reddit)
                }else{
                    Color.clear
                }
            case .Youtube:
                if let youtube = data as? CrybseVideoData{
                    VideoCard(data: youtube, size: .init(width: width, height: totalHeight * 0.3))
                }else{
                    Color.clear
                }
            default:
                Color.clear.frame(width:.zero, height: .zero, alignment: .center)
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

    func infoViewGen(type:PostCardType) -> some View{
        let heading = type == .News ? "News" : type == .Tweet ? "Tweets" : type == .Reddit ? "Reddit" : type  == .Youtube ? "Youtube" : "Posts"
        var data:[Any] = type == .News ? self.News : type == .Tweet ? self.Tweets : type == .Reddit ? self.Reddit : type == .Youtube ? self.Videos : []
        data = data.count < 3 ? data : Array(data[0...2])
        return Container(heading: heading, headingColor: .white, headingDivider: true, headingSize: 20, width: self.size.width  ,horizontalPadding: 15, verticalPadding: 0, orientation: .vertical, aligment: .leading,lazyLoad: true) { w in
            ForEach(Array(data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                self.cardBuilder(width:w,type:type,data: data)
            }
            TabButton(width: w, title: "Load More", action: {
                setWithAnimation {
                    self.showMoreSection = type == .Tweet ? .feed : type == .News ? .news : type == .Reddit ? .reddit : type == .Youtube ? .videos : .none
                }
            }).padding(.vertical)
        }
    }
    
    @ViewBuilder var feedContainer:some View{
        if self.Tweets.isEmpty{
            ProgressView()
        }else if self.Tweets.count >= 5{
            self.infoViewGen(type: .Tweet)
        }
        
    }
    
    @ViewBuilder var newsContainer:some View{
        if self.News.isEmpty{
            ProgressView()
        }else if self.News.count >= 5{
            self.infoViewGen(type: .News)
        }
        
    }
    
    @ViewBuilder var redditContainer:some View{
        if self.Reddit.isEmpty{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }else{
            self.infoViewGen(type: .Reddit)
        }
    }
    
    @ViewBuilder var youtubeContainer:some View{
        if self.Videos.isEmpty{
            
        }else{
            self.infoViewGen(type: .Youtube)
        }
    }
    
    var OHLCV:[CryptoCoinOHLCVPoint]{
        guard let timeSeries = self.socialData?.TimeseriesData else {return []}
        return timeSeries.count >= 10 ? Array(timeSeries[(timeSeries.count - 10)...]) : timeSeries
    }
    
    
    var Prices:CrybseCoinPrices{
        guard let prices = self.assetData.coin?.prices else {return []}
        let length = prices.count
        return length > self.timeSpan ? Array(prices[(length - self.timeSpan)...]) : prices
    }
    
    var priceInfo:some View{
        let asset = self.choosen == -1 ? self.OHLCV.last ?? .init() : self.OHLCV[self.choosen]
        return HStack(alignment: .top, spacing: 20){
            MainSubHeading(heading: "Open", subHeading: convertToMoneyNumber(value: asset.open),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "Low", subHeading: convertToMoneyNumber(value: asset.low),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "High", subHeading: convertToMoneyNumber(value: asset.high),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "Close", subHeading: convertToMoneyNumber(value: asset.close),headingSize: 12.5,subHeadingSize: 17.5)
        }.padding(.vertical)
        .frame(width: self.size.width, height: self.size.height * 0.25, alignment: .topLeading)
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
