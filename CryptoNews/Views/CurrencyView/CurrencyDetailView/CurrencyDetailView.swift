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
    @Binding var currency:AssetData
    var size:CGSize = .init()
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    var asset_feed:[AssetNewsData]
    var news:[AssetNewsData]
    var txns:[Transaction]
    var reloadFeed:(() -> Void)?
    var reloadAsset:(() -> Void)?
    @Binding var showMoreSection:CurrencyViewSection
    
    var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    init(
         info:Binding<AssetData>,
         size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
         asset_feed:[AssetNewsData],
         news:[AssetNewsData],
         txns:[Transaction],
         showSection:Binding<CurrencyViewSection>,
         reloadAsset:(() -> Void)? = nil,
         reloadFeed:(() -> Void)? = nil,
         onClose:(() -> Void)? = nil){
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
    }
}

extension CurrencyDetailView{

    var mainView:some View{
        let views:[AnyView] = [AnyView(self.priceMainInfo),AnyView(self.transactionHistoryView),AnyView(self.CurrencySummary),AnyView(self.SocialMediaMetric),AnyView(self.feedContainer),AnyView(self.newsContainer)]
        return VStack(alignment: .leading, spacing: 10){
            ForEach(Array(views.enumerated()), id: \.offset) { _view in
//                AsyncContainer(size: self.size) {
                    _view.element
//                }
            }
        }.padding(.bottom,150)
    }
    
    var  priceMainInfo:some View{
        VStack(alignment: .leading, spacing: 10) {
            MainSubHeading(heading: "Now", subHeading: convertToMoneyNumber(value: self.price),headingSize: 12.5,subHeadingSize: 17.5).frame(alignment: .leading)
            self.priceInfo
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
    
    var barChartValues:[BarElement]{
        return [BarElement(data: Float(self.currency.tweet_sentiment1 ?? 0), axis_key: "🐻", key: "Very Bearish", info_data: Float(self.currency.tweet_sentiment_impact1 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment2 ?? 0), axis_key: "😞", key: "Bearish", info_data:  Float(self.currency.tweet_sentiment_impact2 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment3 ?? 0), axis_key: "😐", key: "Normal", info_data:  Float(self.currency.tweet_sentiment_impact3 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment4 ?? 0), axis_key: "☺️", key: "Bullish", info_data:  Float(self.currency.tweet_sentiment_impact4 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment5 ?? 0), axis_key: "🐂", key: "Very Bullish", info_data:  Float(self.currency.tweet_sentiment_impact5 ?? 0))]
    }
    
    var SocialMediaMetric:some View{
        Group{
            MainText(content: "Social Media Metrics", fontSize: 25, color: .white,fontWeight: .bold, style: .heading)
            self.Avg_Sentiment
            self.SocialMedia_Metrics
        }
    }
    
    var barTweetChart:AnyView{
        return AnyView(
            BarChart(heading:"Tweet Analytics",bar_elements: self.barChartValues, size: .init(width: size.width, height: size.height * 1.5))
        )
    }
    
    @ViewBuilder var transactionHistoryView:some View{
        Group{
            if !self.txns.isEmpty{
                MarkerMainView(data: .init(crypto_coins: Double(self.coinTotal), value_usd: self.valueTotal,current_val: self.currency.price ?? 0.0, fee: 1.36, totalfee: currency.open ?? 0.0, totalBuys: 1,txns: self.txnForAssetPortfolioData), size: .init(width: size.width, height: size.height * 1.5))
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
        
        
    }
    
    
    func infoViewGen(type:PostCardType) -> some View{
        let title = type == .News ? "News" : type == .Tweet ? "Tweets" : "Reddit"
        let data = type == .News ? self.news  : self.asset_feed
        let view = LazyVStack(alignment: .leading, spacing: 10){
            MainText(content: title, fontSize: 25, color: .white,fontWeight: .bold, style: .heading).padding(.vertical)
            ForEach(Array(data[0...4].enumerated()),id:\.offset){ _data in
                let data = _data.element
                if type == .News{
                    NewsStandCard(news: data,size:.init(width: size.width, height: 200))
                }else{
                    let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                    PostCard(cardType: cardType, data: data, size: self.size,bg: .light, font_color: .white, const_size: false)
                }

            }
            TabButton(width: size.width, title: "Load More", action: {
                withAnimation(.easeInOut) {
                    self.showMoreSection = type == .Tweet ? .feed : type == .News ? .news : .none
                }
            }).padding(.vertical)
        }.padding(.vertical,10)
        
        return view
    
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
    
    var priceInfo:some View{
        let asset = self.choosen == -1 ? self.currency : self.currency.timeSeries?[self.choosen] ?? self.currency
        return HStack(alignment: .top, spacing: 20){
            MainSubHeading(heading: "Open", subHeading: convertToMoneyNumber(value: asset.open),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "Low", subHeading: convertToMoneyNumber(value: asset.low),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "High", subHeading: convertToMoneyNumber(value: asset.high),headingSize: 12.5,subHeadingSize: 17.5)
            MainSubHeading(heading: "Close", subHeading: convertToMoneyNumber(value: asset.close),headingSize: 12.5,subHeadingSize: 17.5)
        }.padding(.vertical)
        .frame(width: self.size.width, height: self.size.height * 0.25, alignment: .topLeading)
    }
    
    var timeSeries:[Float]?{
        return self.currency.timeSeries?.compactMap({$0.close})
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
            return self.currency.price ?? 0.0
        }
    }
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 17.5) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: heading_size, color: .white, fontWeight: .semibold)
            MainText(content: info, fontSize: info_size, color: .white, fontWeight: .regular)
        }
    }
    
    var sentiment_percent:Float{
        guard let avg_sent = self.currency.average_sentiment_calc_24h_previous else{return 0}
        return (avg_sent/5.0) * 100
    }
    
    
    var sentitment_Ts:[Float]{
        return self.currency.timeSeries?.compactMap({$0.average_sentiment}) ?? []
    }
    
    
    var sentiment_set:[Float]{
        var set_senti:Array<Float> = []
        self.sentitment_Ts.forEach { senti in
            if let last = set_senti.last{
                if last != senti{
                    set_senti.append(senti)
                }
            }else{
                set_senti.append(senti)
            }
        }
        return set_senti
    }
    
    func find_sentiment(sentiment:Float) -> String{
        var sentiment_sent:String;
        if sentiment < 3.0 && sentiment > 2.0{
            sentiment_sent = "Bearish 😞"
        }else if sentiment <= 2.0{
            sentiment_sent = "Very Bearish 📉"
        }else if sentiment > 3.0 && sentiment <= 4.0{
            sentiment_sent = "Bullish ☺️"
        }else if sentiment > 4.0{
            sentiment_sent = "Very Bullish 📈"
        }else{
            sentiment_sent = "Normal"
        }
        return sentiment_sent
    }
    
    var Avg_Sentiment:some View{
        ChartCard(header: "Sentiment Time Series", size: .init(width: self.size.width, height: self.size.height)) { w, h in
            let sentiment = self.choosen_sent >= 0 && self.choosen_sent < self.sentiment_set.count - 1 ? self.sentiment_set[self.choosen_sent] : self.currency.average_sentiment ?? 3.0
            let curve_sentiment = self.sentiment_set
//            return
                VStack(alignment: .leading, spacing: 10){
                    MainText(content: self.find_sentiment(sentiment: sentiment), fontSize: 13, color: .white).padding(.leading,5)
                    
                    CurveChart(data: curve_sentiment,choosen: $choosen_sent, interactions: true, size: .init(width: w, height: h * 0.75), bg: .clear, chartShade: true)
                }.frame(width: w, height: h, alignment: .leading)
            
        }
    }
    
    var social_media_metrics_values:[String:Float]{
        return ["Average Sentiment":(self.currency.average_sentiment ?? 0)/5,"Correlation Rank":(self.currency.correlation_rank ?? 0)/5,"Social Impact Score":(self.currency.social_impact_score ?? 0)/5,"Price Score":(self.currency.price_score ?? 0)/5]
    }
    
    func social_media_size ( _ w:CGFloat, _ h:CGFloat) -> CGSize{
        var min = min(w,h)
        min -= min == 0 ? 0 : 35
        return CGSize(width: min , height: min)
    }
    
    var SocialMedia_Metrics:some View{
        ChartCard(header: "Social Media Metrics", size: .init(width: self.size.width, height: self.size.height)) { w, h  in
            DiamondChart(size: self.social_media_size(w, h), percent: self.social_media_metrics_values).zIndex(1)
        }
    }
}
