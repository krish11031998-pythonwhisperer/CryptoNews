//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct CurrencyDetailView: View {
    let interval:Int = 60
    @State var currency:AssetData
    var size:CGSize = .init()
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    @StateObject var asset_feed:FeedAPI
    @StateObject var asset_info:AssetAPI
    @State var time:Int = 0
    var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    init(info:AssetData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.3)){
        self._currency = .init(wrappedValue: info)
        self.size = size
        self._asset_feed = .init(wrappedValue: .init(currency: [info.symbol ?? "BTC"], sources: ["twitter","reddit"], type: .Chronological, limit: 10))
        self._asset_info = .init(wrappedValue: .init(currency: info.symbol ?? "BTC"))
    }
    
    var body:some View{
        VStack(alignment: .leading, spacing: 25){
            self.text(heading: "Now", info:convertToMoneyNumber(value: self.price))
            self.priceInfo
            self.curveChart
                .clipShape(RoundedRectangle(cornerRadius: 15))
            self.transactionHistoryView
            self.Avg_Sentiment
            self.SocialMedia_Metrics
            self.barTweetChart
            self.feedContainer
        }.onAppear(perform: self.onAppear)
        .onReceive(self.timer, perform: { _ in self.checkTimer()})
        .onReceive(self.asset_info.$data, perform: { _ in
            self.onReceiveNewAssetInfo(asset: self.asset_info.data)
        })
    }
    
    
    func checkTimer(){
        if self.time == 0{
            self.time += interval
        }else{
            self.asset_info.getAssetInfo()
        }
    }

    func onReceiveNewAssetInfo(asset:AssetData?){
        guard let data = asset else {return}
        DispatchQueue.main.async {
            self.currency = data
            print("(DEBUG): Updated the Asset Data!")
        }
    }
    
}

extension CurrencyDetailView{

    func onAppear(){
        if self.asset_feed.FeedData.isEmpty{
            self.asset_feed.getAssetInfo()
        }
    }
    
    var barChartValues:[BarElement]{
        return [BarElement(data: Float(self.currency.tweet_sentiment1 ?? 0), axis_key: "🐻", key: "Very Bearish", info_data: Float(self.currency.tweet_sentiment_impact1 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment2 ?? 0), axis_key: "😞", key: "Bearish", info_data:  Float(self.currency.tweet_sentiment_impact2 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment3 ?? 0), axis_key: "😐", key: "Normal", info_data:  Float(self.currency.tweet_sentiment_impact3 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment4 ?? 0), axis_key: "☺️", key: "Bullish", info_data:  Float(self.currency.tweet_sentiment_impact4 ?? 0)),BarElement(data: Float(self.currency.tweet_sentiment5 ?? 0), axis_key: "🐂", key: "Very Bullish", info_data:  Float(self.currency.tweet_sentiment_impact5 ?? 0))]
    }
    
    var barTweetChart:AnyView{
        return AnyView(
            BarChart(heading:"Tweet Analytics",bar_elements: self.barChartValues, size: .init(width: size.width, height: size.height * 1.5))
        
        )
    }
    
    var transactionHistoryView:some View{
        MarkerMainView(data: .init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1,txns: [.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1)]),size: .init(width: size.width, height: size.height * 1.5))
    }
    
    
    var feedComponent:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "Feed", fontSize: 25, color: .white,fontWeight: .bold)
            ForEach(Array(self.asset_feed.FeedData.enumerated()),id:\.offset){ _data in
                let data = _data.element
                let cardType:PostCardType = data.twitter_screen_name != nil ? .Tweet : .Reddit
                PostCard(cardType: cardType, data: data, size: self.size, font_color: .white, const_size: false)
            }
        }.transition(.opacity)
    }
    
    var feedContainer:AnyView{
        if self.asset_feed.FeedData.isEmpty{
            return AnyView(ProgressView())
        }else{
            return AnyView(
                self.feedComponent
            )
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
    
    func text(heading:String,info:String,heading_size:CGFloat = 12.5,info_size:CGFloat = 20) -> some View{
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
            return AnyView(
                VStack(alignment: .leading, spacing: 10){
                    MainText(content: self.find_sentiment(sentiment: sentiment), fontSize: 13, color: .white).padding(.leading,5)
                    
                    CurveChart(data: curve_sentiment,choosen: $choosen_sent, interactions: true, size: .init(width: w, height: h * 0.75), bg: .clear, chartShade: true)
                }.frame(width: w, height: h, alignment: .leading)
            )
        }
    }
    
    var SocialMedia_Metrics:some View{
        ChartCard(header: "Social Media Metrics", size: .init(width: self.size.width, height: self.size.height)) { w, h in
            var min = min(w,h)
            min -= min == 0 ? 0 : 35
            let size = CGSize(width: min , height: min)
            
            let values = ["Average Sentiment":(self.currency.average_sentiment ?? 0)/5,"Correlation Rank":(self.currency.correlation_rank ?? 0)/5,"Social Impact Score":(self.currency.social_impact_score ?? 0)/5,"Price Score":(self.currency.price_score ?? 0)/5]
            let view = DiamondChart(size: size, percent: values).zIndex(1)
                
            return AnyView(view)
        }
    }
}

private struct testView:View{
    @StateObject var asset:AssetAPI = .init(currency: "ETH")
    
    func onAppear(){
        self.asset.getAssetInfo()
    }
    
    var body: some View{
        Container(heading: "\(self.asset.currency)") { w in
            return AnyView(
                ZStack(alignment: .center){
                    if let data = self.asset.data{
                        CurrencyDetailView(info: data)
                    }else{
                        ProgressView()
                    }
                }
            )
        }.onAppear(perform : self.onAppear)
    }
}


struct CurrencyDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false){
            testView()
        }
        .padding(.top,50)
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
        
    }
}
