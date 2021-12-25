//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct CurrencyDetailView: View {
    @EnvironmentObject var context:ContextData
    var onClose:(() -> Void)?
    @Binding var currency:CoinData
    var size:CGSize = .init()
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    var asset_feed:[AssetNewsData]
    var news:[AssetNewsData]
    var txns:[Transaction]
    var reloadFeed:(() -> Void)?
    var reloadAsset:(() -> Void)?
    @Binding var showMoreSection:CurrencyViewSection
    @Binding var ohclv:CryptoCoinOHLCV?
    
    var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    init(
         info:Binding<CoinData>,
         ohlcv:Binding<CryptoCoinOHLCV?>? = nil,
         size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
         asset_feed:[AssetNewsData],
         news:[AssetNewsData],
         txns:[Transaction],
         showSection:Binding<CurrencyViewSection>,
         reloadAsset:(() -> Void)? = nil,
         reloadFeed:(() -> Void)? = nil,
         onClose:(() -> Void)? = nil){
        self._ohclv = ohlcv ?? .constant(nil)
        self._currency = info
        self.onClose = onClose
        self.size = size
        self.asset_feed = asset_feed
        self._showMoreSection = showSection
        self.txns = txns
        self.news = news
    }
    
    
    var body:some View{
        self.mainView
            .onAppear {
                print("(DEBUG) The Coin Data : ",self.currency.Name)
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
    
    var  priceMainInfo:some View{
        VStack(alignment: .leading, spacing: 10) {
            MainSubHeading(heading: "Now", subHeading: convertToMoneyNumber(value: self.price),headingSize: 12.5,subHeadingSize: 17.5).frame(alignment: .leading)
            if !self.OHLCV.isEmpty{
                self.priceInfo
            }
            self.curveChart.clipContent(clipping: .roundClipping)
        }
    }
    
    var coinTotal:Float{
        return self.txns.reduce(0, {$0 + ($1.type == "sell" ? -1 : 1) * $1.asset_quantity})
    }

    var valueTotal:Float{
        return self.txns.reduce(0, {$0 + ($1.type == "sell" ? -1 : 1) * $1.total_inclusive_price})
    }

    var txnForAssetPortfolioData:[PortfolioData]{
        return self.txns.compactMap({$0.parseToPortfolioData()})
    }
    
    var CurrencySummary:some View{
        ChartCard(header: "Statistics", size: self.size) { w, h in
            CurrencySummaryView(currency: currency, size: .init(width: w, height: h))
        }
    }
    
    
    @ViewBuilder var transactionHistoryView:some View{
        if !self.txns.isEmpty{
            MarkerMainView(data: .init(crypto_coins: Double(self.coinTotal), value_usd: self.valueTotal,current_val: self.currency.Price, fee: 1.36, totalfee: 0.0, totalBuys: 1,txns: self.txnForAssetPortfolioData), size: .init(width: size.width, height: size.height * 1.5))
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
            if let sym = self.currency.symbol,self.context.selectedSymbol != sym{
                self.context.selectedSymbol = sym
            }
        }
    }
    
    var infoSection:some View{
        Container(heading: "About", width: self.size.width, ignoreSides: false, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
            MainText(content:"What is \(self.currency.Symbol)", fontSize: 17.5, color: .white, fontWeight: .semibold)
                .frame(width: w, alignment: .leading)
            ForEach(self.currency.Description.split(separator: "\n"), id:\.self) { text in
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
    }
    
    
    @ViewBuilder func infoViewGen(type:PostCardType) -> some View{
        let title = type == .News ? "News" : type == .Tweet ? "Tweets" : "Reddit"
        let data = type == .News ? self.news  : self.asset_feed
        let view = VStack(alignment: .leading, spacing: 10){
            MainText(content: title, fontSize: 25, color: .white,fontWeight: .bold, style: .heading).padding(.vertical)
            ForEach(Array(data[0...4].enumerated()),id:\.offset){ _data in
                let data = _data.element
                if type == .News{
                    NewsStandCard(news: data,size:.init(width: size.width, height: 200))
                }else{
                    let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                    PostCard(cardType: cardType, data: data, size: self.size,bg: .light, const_size: false)
                }

            }
            TabButton(width: size.width, title: "Load More", action: {
                withAnimation(.easeInOut) {
                    self.showMoreSection = type == .Tweet ? .feed : type == .News ? .news : .none
                }
            }).padding(.vertical)
        }
        view
    
    }
    
    var feedView:some View{
        self.infoViewGen(type: .Tweet)
    }
    
    var newsView:some View{
        self.infoViewGen(type: .News)
    }
    
    @ViewBuilder var feedContainer:some View{
        if self.asset_feed.isEmpty{
            ProgressView()
        }else if self.news.count >= 5{
            self.feedView
        }
        
    }
    
    @ViewBuilder var newsContainer:some View{
        if self.news.isEmpty{
            ProgressView()
        }else if self.news.count >= 5{
            self.newsView
        }
        
    }
    
    var OHLCV:[CryptoCoinOHLCVPoint]{
        return self.ohclv?.Data ?? []
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
    
    var timeSeries:[Float]?{
        return !self.OHLCV.isEmpty ? self.OHLCV.compactMap({$0.close}) : self.currency.Sparkline
    }
    
    var curveChart:some View{
        ZStack(alignment: .center){
            if let tS = self.timeSeries{
                CurveChart(data: tS,choosen: $choosen,interactions: true,size: self.size, bg: .clear,chartShade: true)
                    
            }else{
                MainText(content: "NO Time Series Data", fontSize: 20, color: .white, fontWeight: .bold)
            }
        }
    }
    
    
    var price:Float{
        guard let tS = self.timeSeries else {return 0.0}
        if self.choosen > 0 && self.choosen < tS.count{
            return tS[self.choosen]
        }else{
            return self.currency.Price
        }
    }
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 17.5) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: heading_size, color: .white, fontWeight: .semibold)
            MainText(content: info, fontSize: info_size, color: .white, fontWeight: .regular)
        }
    }
    
//    var sentiment_percent:Float{
//        guard let avg_sent = self.currency.average_sentiment_calc_24h_previous else{return 0}
//        return (avg_sent/5.0) * 100
//    }
//
//
//    var sentitment_Ts:[Float]{
//        return self.currency.timeSeries?.compactMap({$0.average_sentiment}) ?? []
//    }
    
    
//    var sentiment_set:[Float]{
//        var set_senti:Array<Float> = []
//        self.sentitment_Ts.forEach { senti in
//            if let last = set_senti.last{
//                if last != senti{
//                    set_senti.append(senti)
//                }
//            }else{
//                set_senti.append(senti)
//            }
//        }
//        return set_senti
//    }
//
//    func find_sentiment(sentiment:Float) -> String{
//        var sentiment_sent:String;
//        if sentiment < 3.0 && sentiment > 2.0{
//            sentiment_sent = "Bearish 😞"
//        }else if sentiment <= 2.0{
//            sentiment_sent = "Very Bearish 📉"
//        }else if sentiment > 3.0 && sentiment <= 4.0{
//            sentiment_sent = "Bullish ☺️"
//        }else if sentiment > 4.0{
//            sentiment_sent = "Very Bullish 📈"
//        }else{
//            sentiment_sent = "Normal"
//        }
//        return sentiment_sent
//    }
    
//    var Avg_Sentiment:some View{
//        ChartCard(header: "Sentiment Time Series", size: .init(width: self.size.width, height: self.size.height)) { w, h in
//            let sentiment = self.choosen_sent >= 0 && self.choosen_sent < self.sentiment_set.count - 1 ? self.sentiment_set[self.choosen_sent] : self.currency.average_sentiment ?? 3.0
//            let curve_sentiment = self.sentiment_set
////            return
//                VStack(alignment: .leading, spacing: 10){
//                    MainText(content: self.find_sentiment(sentiment: sentiment), fontSize: 13, color: .white).padding(.leading,5)
//
//                    CurveChart(data: curve_sentiment,choosen: $choosen_sent, interactions: true, size: .init(width: w, height: h * 0.75), bg: .clear, chartShade: true)
//                }.frame(width: w, height: h, alignment: .leading)
//
//        }
//    }
//
//    var social_media_metrics_values:[String:Float]{
//        return ["Average Sentiment":(self.currency.average_sentiment ?? 0)/5,"Correlation Rank":(self.currency.correlation_rank ?? 0)/5,"Social Impact Score":(self.currency.social_impact_score ?? 0)/5,"Price Score":(self.currency.price_score ?? 0)/5]
//    }
    
    func social_media_size ( _ w:CGFloat, _ h:CGFloat) -> CGSize{
        var min = min(w,h)
        min -= min == 0 ? 0 : 35
        return CGSize(width: min , height: min)
    }
    
//    var SocialMedia_Metrics:some View{
//        ChartCard(header: "Social Media Metrics", size: .init(width: self.size.width, height: self.size.height)) { w, h  in
//            DiamondChart(size: self.social_media_size(w, h), percent: self.social_media_metrics_values).zIndex(1)
//        }
//    }
}
