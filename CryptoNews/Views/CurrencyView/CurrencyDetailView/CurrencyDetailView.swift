//
//  CurrencyDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/09/2021.
//

import SwiftUI

struct CurrencyDetailView: View {
    var currency:AssetData
    var size:CGSize = .init()
    @State var choosen:Int = -1
    @State var choosen_sent:Int = -1
    init(info:AssetData,size:CGSize){
        self.currency = info
        self.size = size
    }
        
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            self.text(heading: "Now", info:convertToMoneyNumber(value: self.price))
            self.priceInfo
            self.curveChart
                .clipShape(RoundedRectangle(cornerRadius: 15))
            self.Avg_Sentiment
        }
    }
}

extension CurrencyDetailView{
    var priceInfo:some View{
        let asset = self.choosen == -1 ? self.currency : self.currency.timeSeries?[self.choosen] ?? self.currency
        return HStack(alignment: .top, spacing: 20){
            self.text(heading: "Open", info: convertToMoneyNumber(value: asset.open))
            self.text(heading: "Low", info: convertToMoneyNumber(value: asset.low))
            self.text(heading: "High", info: convertToMoneyNumber(value: asset.high))
            self.text(heading: "Close", info: convertToMoneyNumber(value: asset.close))
        }.padding(.vertical).frame(width: self.size.width, alignment: .topLeading)
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
    
    var Avg_Sentiment:some View{
        ChartCard(header: "Sentiment", size: .init(width: self.size.width, height: self.size.height)) { w, h in
            let sentiment = self.choosen_sent >= 0 && self.choosen_sent < self.sentiment_set.count - 1 ? self.sentiment_set[self.choosen_sent] : self.currency.average_sentiment ?? 3.0
            let curve_sentiment = self.sentiment_set
            return AnyView(
                    VStack(alignment: .leading, spacing: 10){
//
//                        HStack(alignment: .center, spacing: 10){
////                            self.text(heading: "Avg.Sentiment", info: "\(self.currency.average_sentiment ?? 3.0)")
//                            self.text(heading: "Sentiment", info: "\(sentiment)")
//                        }.padding(.horizontal,5).frame(height: h * 0.1)
                        
                        CurveChart(data: curve_sentiment,choosen: $choosen_sent, interactions: true, size: .init(width: w, height: h * 0.75), bg: .clear, chartShade: true)
                    }.frame(width: w, height: h, alignment: .leading)
                )
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
                        CurrencyDetailView(info: data,size: .init(width: w, height: totalHeight * 0.3))
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
