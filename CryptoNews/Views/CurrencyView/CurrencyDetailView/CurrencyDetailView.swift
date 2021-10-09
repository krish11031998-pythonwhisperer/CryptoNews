//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct CurrencyDetailView: View {
    var onClose:(() -> Void)?
    @Binding var currency:AssetData
    var size:CGSize = .init()
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    @Binding var asset_feed:[AssetNewsData]
    var reloadFeed:(() -> Void)?
    var reloadAsset:(() -> Void)?
    @Binding var showMoreView:Bool
    @Binding var txns:[Transaction]
    var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    init(
//        heading:String,
         info:Binding<AssetData>,
         size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3),
         asset_feed:Binding<[AssetNewsData]>,
         showMoreView:Binding<Bool>,
         txns:Binding<[Transaction]>,
         reloadAsset:(() -> Void)? = nil,
         reloadFeed:(() -> Void)? = nil,
         onClose:(() -> Void)? = nil){
        self._currency = info
//        self.heading = heading
        self.onClose = onClose
        self.size = size
        self._asset_feed = asset_feed
        self._showMoreView = showMoreView
        self._txns = txns
    }
    
    var body:some View{
        self.mainView
        
    }
}

extension CurrencyDetailView{


    
    func onCloseFeed(){
        withAnimation(.easeInOut) {
            self.showMoreView = false
        }
    }
    

    var mainView:some View{
            LazyVStack(alignment: .leading, spacing: 25){
                HStack(alignment: .center, spacing: 4) {
                    self.text(heading: "Now", info:convertToMoneyNumber(value: self.price))
                    Spacer()
                    if let reloadFeed = self.reloadFeed{
                        SystemButton(b_name: "arrow.clockwise", b_content: "Refresh", color: .white, haveBG: true, bgcolor: .black, alignment: .vertical, action: reloadFeed)
                    }
                    
                }
                self.priceInfo
                self.curveChart.clipContent(clipping: .roundClipping)
                self.transactionHistoryView
                self.CurrencySummary
                self.SocialMediaMetric
                self.feedContainer
            }
    }
    
    var txnsForAsset:[Transaction]{
        return self.txns.filter({$0.symbol?.lowercased() == self.currency.symbol?.lowercased()})
    }
    
    var coinTotal:Float{
        return self.txnsForAsset.reduce(0, {$0 + ($1.type == "sell" ? -1 : 1) * $1._asset_quantity})
    }

    var valueTotal:Float{
        return self.txnsForAsset.reduce(0, {$0 + ($1.type == "sell" ? -1 : 1) * $1._asset_spot_price * $1._asset_quantity})
    }

    var txnForAssetPortfolioData:[PortfolioData]{
        return self.txnsForAsset.compactMap({$0.parseToPortfolioData()})
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
            MainText(content: "Social Media Metrics", fontSize: 25, color: .white, fontWeight: .bold)
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
        if self.txnsForAsset.isEmpty{
//            ProgressView()
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }else{
            MarkerMainView(data: .init(crypto_coins: Double(self.coinTotal), value_usd: self.valueTotal, fee: 1.36, totalfee: currency.open ?? 0.0, totalBuys: 1,txns: self.txnForAssetPortfolioData),size: .init(width: size.width, height: size.height * 1.5))
        }
        
    }
    
    
    var feed:some View{
        Group{
            MainText(content: "Feed", fontSize: 25, color: .white,fontWeight: .bold)
            ForEach(Array(self.asset_feed.enumerated()),id:\.offset){ _data in
                let data = _data.element
                let idx = _data.offset
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: self.size, font_color: .white, const_size: false)
            }
            TabButton(width: size.width, title: "Load More", action: {
                withAnimation(.easeInOut) {
                    self.showMoreView = true
                }
            })
                .padding(.bottom,50)
        }
    }
    
    @ViewBuilder var feedContainer:some View{
        if self.asset_feed.isEmpty{
            ProgressView()
        }else{
            self.feed
        }
        
    }
    
    var priceInfo:some View{
        let asset = self.choosen == -1 ? self.currency : self.currency.timeSeries?[self.choosen] ?? self.currency
        return HStack(alignment: .top, spacing: 20){
            self.text(heading: "Open", info: convertToMoneyNumber(value: asset.open))
            self.text(heading: "Low", info: convertToMoneyNumber(value: asset.low))
            self.text(heading: "High", info: convertToMoneyNumber(value: asset.high))
            self.text(heading: "Close", info: convertToMoneyNumber(value: asset.close))
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
//            var min = min(w,h)
//            min -= min == 0 ? 0 : 35
//            let size = CGSize(width: min , height: min)
//
//            let values = ["Average Sentiment":(self.currency.average_sentiment ?? 0)/5,"Correlation Rank":(self.currency.correlation_rank ?? 0)/5,"Social Impact Score":(self.currency.social_impact_score ?? 0)/5,"Price Score":(self.currency.price_score ?? 0)/5]
//            let view =
            
            DiamondChart(size: self.social_media_size(w, h), percent: self.social_media_metrics_values).zIndex(1)
                
//            view
        }
    }
}
