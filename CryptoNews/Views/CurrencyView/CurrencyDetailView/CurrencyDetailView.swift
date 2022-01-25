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
    @State var showMoreSection:CurrencyViewSection = .none
    @StateObject var timeSeriesAPI:CrybseTimeseriesPriceAPI
    @ObservedObject var assetData: CrybseAsset
    var size:CGSize = .init()
    @State var timeCounter:Int = 0
    @State var refresh:Bool = false
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    init(
        assetData:CrybseAsset,
        size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3)
    )
    {
             
        self.assetData = assetData
        self._timeSeriesAPI = .init(wrappedValue: .init(currency: assetData.currency, limit: 1, fiat: "USD"))
        self.size = size
    }
    
    
    var body:some View{
        self.mainView
            .preference(key: ShowSectionPreferenceKey.self, value: self.showMoreSection)
            .onAppear {
                print("(DEBUG) The Coin Data : ",self.assetData.currency ?? "XXX")
            }
            .onReceive(self.timer, perform: self.OnReceiveTimer)
            .onDisappear {
                self.timer.upstream.connect().cancel()
            }
            .onReceive(self.timeSeriesAPI.$timeseriesData, perform: self.onReceiveNewTimeseriesData(timeSeries:))
    }
}

extension CurrencyDetailView{
        
    @ViewBuilder var mainView:some View{
        self.priceMainInfo
        self.transactionHistoryView
//        self.TradingSignalsView
        self.paginatedViews.padding(.top,10)
//        self.feedContainer
//        self.newsContainer
    }
    
    var CurrencyGeneralView:some View{
        VStack(alignment: .leading, spacing: 10) {
            self.CurrencySummary
            self.infoSection
        }
    }
    
    var headingFontSize:CGFloat{
        return 25
    }

    var socialData:CrybseCoinData?{
        return self.assetData.coin
    }
    
    func OnReceiveTimer(_ time:Date){
        if self.timeCounter < 60{
            setWithAnimation {
                self.timeCounter += 1
            }
        }else if !self.timeSeriesAPI.loading{
            self.timeSeriesAPI.refreshTimseriesPrice()
        }
    }
    
    var loadingPriceView:some View{
        let percent = (1 - Float(self.timeCounter)/Float(60)) * Float(100)
        
        return HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: "Now", subHeading: convertToMoneyNumber(value: self.price),headingSize: 12.5,subHeadingSize: 17.5).frame(alignment: .leading)
            Spacer()
            if self.timeSeriesAPI.loading{
                ProgressView().frame(width: 30, height: 30, alignment: .center)
            }else{
                CircleChart(percent: percent, size: .init(width: 20, height: 20), widthFactor: 0.15)
            }
        }.frame(width: self.size.width, alignment: .center)
    }
    
    var  priceMainInfo:some View{
        VStack(alignment: .leading, spacing: 10) {
            self.loadingPriceView
            if !self.OHLCV.isEmpty{
                self.priceInfo
            }
            self.curveChart.clipContent(clipping: .roundClipping)
        }
    }
    
    var News:[CryptoNews]{
        return self.socialData?.News ?? []
    }
    
    var Tweets:[AssetNewsData]{
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
        ButtonScrollView(headerviews: ["General":AnyView(self.CurrencyGeneralView),"Twitter":AnyView(self.feedContainer),"News":AnyView(self.newsContainer)], width: self.size.width)
    }
    
    var profit:Float{
        if self.choosen != -1,let selectedPrice = self.OHLCV[self.choosen].close{
            return self.assetData.txns?.map({$0.asset_quantity * (selectedPrice - $0.asset_spot_price)}).reduce(0, {$0 == 0 ? $1 : $0 + $1}) ?? self.assetData.Profit
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
                TabButton(width: self.size.width * 0.5 - 5, height: 50, title: "View Portfolio", textColor: .white,action: self.viewPortfolio)
                TabButton(width: self.size.width * 0.5 - 5, height: 50, title: "Add a New Txn", textColor: .white,action: self.handleAddTxn)
            }.frame(width: self.size.width, alignment: .center)
        }else{
            TabButton(width: self.size.width, height: 50, title: "Add a New Txn", textColor: .white,action: self.handleAddTxn)
        }
        
    }
    
    @ViewBuilder var infoSection:some View{
        if let coinMetaData = self.socialData?.MetaData{
            Container(heading: "About",headingSize: headingFontSize, width: self.size.width, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
                MainText(content:"What is \(coinMetaData.Symbol)", fontSize: 17.5, color: .white, fontWeight: .semibold)
                    .frame(width: w, alignment: .leading)
                ForEach(coinMetaData.Description.split(separator: "\n"), id:\.self) { text in
                    if text.contains("<p>") && text.contains("</p>") {
                        MainText(content: text.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: ""), fontSize: 15, color: .white, fontWeight: .regular)
                            .frame(width: w, alignment: .leading)
                    }else{
                        MainText(content: text.replacingOccurrences(of: "<h3>", with: "").replacingOccurrences(of: "</h3>", with: ""), fontSize: 17.5, color: .white, fontWeight: .semibold)
                            .frame(width: w, alignment: .leading)
                    }
                }
            }
            .basicCard(size: .zero)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
       
    }
    
    
    @ViewBuilder func cardBuilder(data:Any) -> some View{
        if let news = data as? CryptoNews{
            NewsStandCard(news: news,size:.init(width: size.width, height: 200))
        }else if let post = data as? AssetNewsData{
            PostCard(cardType: .Tweet, data: post, size: self.size,bg: .light, const_size: false)
        }else{
            Color.clear.frame(width:.zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder var TradingSignalsView : some View{
        if let tradingSignal = self.assetData.coin?.tradingSignals{
            self.tradingSignalViews(tradingSignal: tradingSignal)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }

    @ViewBuilder func tradingSignalViews(tradingSignal:CrybseTradingSignalsData) -> some View{
        let order = ["In Out Var","Addresses Net Growth","Concentration Var","Largest XS Var"]
        if tradingSignal.overall == 0{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }else{
            Container(heading: "Trading Signals",headingSize: headingFontSize,width: self.size.width,ignoreSides: false,verticalPadding: 15,orientation: .horizontal) { w in
                MainSubHeading(heading: tradingSignal.getEmoji, subHeading: tradingSignal.getSentiment, headingSize: 40, subHeadingSize: 18, orientation: .vertical, alignment: .center)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(order,id:\.self){ key in
                        if let value = tradingSignal.tradingSignalValues[key]{
                            MainSubHeading(heading: key , subHeading: value.0.ToDecimals(), headingSize: 14, subHeadingSize: 20, headColor: .gray, subHeadColor: .white, orientation: .vertical, alignment: .leading)
                        }
                    }
                }.frame(width: w * 0.55, alignment: .center)
                
            }.basicCard(size: .zero)
        }
    }
        
    
    func infoViewGen(type:PostCardType) -> some View{
        let title = type == .News ? "News" : type == .Tweet ? "Tweets" : "Reddit"
        var data:[Any] = type == .News ? self.News : self.Tweets
        data = data.count < 5 ? data : Array(data[0...4])
        return Container(headingDivider: false, width: self.size.width, ignoreSides: true) { w in
            VStack(alignment: .center, spacing: 10) {
                ForEach(Array(data.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    self.cardBuilder(data: data)
                        .aspectRatio(contentMode: .fit)
                }
                TabButton(width: size.width, title: "Load More", action: {
                    setWithAnimation {
                        self.showMoreSection = type == .Tweet ? .feed : type == .News ? .news : .none
                    }
                }).padding(.vertical)
            }
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
    
    var OHLCV:[CryptoCoinOHLCVPoint]{
        guard let timeSeries = self.socialData?.TimeseriesData else {return []}
        return timeSeries.count >= 10 ? Array(timeSeries[(timeSeries.count - 10)...]) : timeSeries
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
            if !self.OHLCV.isEmpty{
                CurveChart(data: OHLCV.compactMap({$0.close}),choosen: $choosen,interactions: true,size: self.size, bg: .clear,chartShade: true)
            }else{
                MainText(content: "NO Time Series Data", fontSize: 20, color: .white, fontWeight: .bold)
            }
        }
    }
    
    
    var price:Float{
        if self.choosen > 0 && self.choosen < self.OHLCV.count{
            return self.OHLCV[self.choosen].close ?? 0
        }else if let latestPrice = self.OHLCV.last?.close{
            return latestPrice
        }else{
            return self.socialData?.MetaData.Price ?? 0
        }
    }
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 17.5) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: heading_size, color: .white, fontWeight: .semibold)
            MainText(content: info, fontSize: info_size, color: .white, fontWeight: .regular)
        }
    }
    
    func onReceiveNewTimeseriesData(timeSeries:Array<CryptoCoinOHLCVPoint>?){
        guard let safeTimeseries = timeSeries else {return}
        setWithAnimation {
            let latestPrices = safeTimeseries.compactMap({$0.time != nil ? $0.time! >= self.assetData.LatestPriceTime + 60 ? $0 : nil : nil})
            for count in 0..<latestPrices.count{
                let latestPrice = latestPrices[count]
                self.assetData.coin?.TimeseriesData.append(latestPrice)
                if let latestClosePrice = latestPrice.close,count == (latestPrices.count - 1){
                    let newValue = self.coinTotal * latestClosePrice
                    self.assetData.profit = self.assetData.Profit + (newValue - self.assetData.Value)
                    self.assetData.value = newValue
                    self.assetData.Price = latestClosePrice
                }
            }
            self.timeCounter = 0
        }
    }
    
    func social_media_size ( _ w:CGFloat, _ h:CGFloat) -> CGSize{
        var min = min(w,h)
        min -= min == 0 ? 0 : 35
        return CGSize(width: min , height: min)
    }
}
