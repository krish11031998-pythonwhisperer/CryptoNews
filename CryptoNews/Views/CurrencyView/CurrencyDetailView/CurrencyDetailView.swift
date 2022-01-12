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
        self.size = size
    }
    
    
    var body:some View{
        self.mainView
            .preference(key: ShowSectionPreferenceKey.self, value: self.showMoreSection)
            .onAppear {
                print("(DEBUG) The Coin Data : ",self.assetData.currency ?? "XXX")
            }
            .onReceive(self.timer) { _ in
                setWithAnimation {
                    if self.timeCounter < 60{
                        self.timeCounter += 1
                    }else if !self.refresh{
                        self.refresh.toggle()
                    }
                }
                
            }
            .onDisappear {
                self.timer.upstream.connect().cancel()
            }
            .onChange(of: self.refresh) { newValue in
                if self.refresh{
                    self.refreshPrices()
                }
            }
    }
}

extension CurrencyDetailView{
        
    @ViewBuilder var mainView:some View{
        self.priceMainInfo
        self.transactionHistoryView
        self.CurrencySummary
        self.infoSection
        self.feedContainer
        self.newsContainer
    }
    

    var socialData:CrybseCoinSocialData?{
        return self.assetData.coin
    }
    
    var loadingPriceView:some View{
        let percent = (1 - Float(self.timeCounter)/Float(60)) * Float(100)
        
        return HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: "Now", subHeading: convertToMoneyNumber(value: self.price),headingSize: 12.5,subHeadingSize: 17.5).frame(alignment: .leading)
            Spacer()
            if self.refresh{
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
    
    var profit:Float{
        return self.assetData.Profit
    }
    
    var txnForAssetPortfolioData:[PortfolioData]{
        return self.txns.compactMap({$0.parseToPortfolioData()})
    }
    
    var CurrencySummary:some View{
        ChartCard(header: "Statistics", size: self.size) { w, h in
            CurrencySummaryView(currency: self.socialData?.MetaData ?? .init(), size: .init(width: w, height: h))
        }
    }
    
    
    @ViewBuilder var transactionHistoryView:some View{
        if !self.txns.isEmpty{
            MarkerMainView(data: .init(crypto_coins: Double(self.coinTotal), value_usd: self.valueTotal,profit: self.profit, fee: 1.36, totalfee: 0.0, totalBuys: 1,txns: self.txnForAssetPortfolioData), size: .init(width: size.width, height: size.height * 1.5))
            TabButton(width: self.size.width, height: 50, title: "View Portfolio", textColor: .white) {
                withAnimation(.easeInOut) {
                    self.showMoreSection = .txns
                }
            }
        }
        TabButton(width: self.size.width, height: 50, title: "Add a New Txn", textColor: .white) {
            if !self.context.addTxn{
                self.context.addTxn.toggle()
            }
            if self.context.selectedSymbol != self.assetData.Currency{
                self.context.selectedSymbol = self.assetData.Currency
            }
        }
    }
    
    @ViewBuilder var infoSection:some View{
        if let coinMetaData = self.socialData?.MetaData{
            Container(heading: "About", width: self.size.width, ignoreSides: false, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
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
            }.background(BlurView(style: .dark))
            .clipContent(clipping: .roundClipping)
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
    
    func infoViewGen(type:PostCardType) -> some View{
        let title = type == .News ? "News" : type == .Tweet ? "Tweets" : "Reddit"
        var data:[Any] = type == .News ? self.News : self.Tweets
        data = data.count < 5 ? data : Array(data[0...4])
        let view = VStack(alignment: .leading, spacing: 10){
            MainText(content: title, fontSize: 25, color: .white,fontWeight: .bold, style: .heading).padding(.vertical)
            ForEach(Array(data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                self.cardBuilder(data: data)
            }
            TabButton(width: size.width, title: "Load More", action: {
                withAnimation(.easeInOut) {
                    self.showMoreSection = type == .Tweet ? .feed : type == .News ? .news : .none
                }
            }).padding(.vertical)
        }
        return view
    }
    
    var feedView:some View{
        self.infoViewGen(type: .Tweet)
    }
    
    var newsView:some View{
        self.infoViewGen(type: .News)
    }
    
    @ViewBuilder var feedContainer:some View{
        if self.Tweets.isEmpty{
            ProgressView()
        }else if self.Tweets.count >= 5{
            self.feedView
        }
        
    }
    
    @ViewBuilder var newsContainer:some View{
        if self.News.isEmpty{
            ProgressView()
        }else if self.News.count >= 5{
            self.newsView
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
            return self.socialData?.MetaData?.Price ?? 0
        }
    }
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 17.5) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: heading_size, color: .white, fontWeight: .semibold)
            MainText(content: info, fontSize: info_size, color: .white, fontWeight: .regular)
        }
    }
    
    func refreshPrices(){
        CrybseTimeseriesPriceAPI.shared.getPrice(currency: self.assetData.Currency,limit: 1,fiat: "USD") { data in
            setWithAnimation {
//            withAnimation(.easeInOut){
                if let safeTimeseries = CrybseTimeseriesPriceAPI.parseData(data: data){
                    let latestPrices = safeTimeseries.compactMap({$0.time != nil ? $0.time! >= self.assetData.LatestPriceTime + 60 ? $0 : nil : nil})
                    if let latestPrice = latestPrices.last?.close{
                        self.assetData.coin?.TimeseriesData?.append(contentsOf: latestPrices)
                        let newValue = self.coinTotal * latestPrice
                        print("(DEBUG) NewValue : ",newValue)
                        self.assetData.profit = self.assetData.Profit + (newValue - self.assetData.Value)
                        self.assetData.value = newValue
                    }
                }
            }
            
            setWithAnimation {
                self.refresh.toggle()
                self.timeCounter = 0
            }
        }
    }
    
    func social_media_size ( _ w:CGFloat, _ h:CGFloat) -> CGSize{
        var min = min(w,h)
        min -= min == 0 ? 0 : 35
        return CGSize(width: min , height: min)
    }
}
