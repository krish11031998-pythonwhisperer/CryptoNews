//
//  SentimentsSnapshot.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/04/2022.
//

import SwiftUI

struct SentimentsSnapshot: View {
    var sentiment:CrybseSentiment
    var width:CGFloat
    var height:CGFloat?

    
    init(sentiment:CrybseSentiment,width:CGFloat,height:CGFloat? = nil){
        self.sentiment = sentiment
        self.width = width
        self.height = height
    }
    
    var sentimentTotalScore:Float{
        return self.sentiment.total?.sentiment_score ?? 0.0
    }
    
    var sentimentTotalColor:Color{
        return self.sentimentTotalScore == 0 ? .gray : self.sentimentTotalScore > 0 ? .green : .red
    }
    
    
    @ViewBuilder func sentimentBreakdown(w:CGFloat) -> some View{
        if let totalSentiment = self.sentiment.total{
            HStack(alignment: .center, spacing: 10) {
                DonutChart(selectedColor: nil, diameter: w * 0.45, lineWidth: 12.5, valueColorPair: [.red:Float(totalSentiment.negative ?? 0),.green:Float(totalSentiment.positive ?? 0),.gray:Float(totalSentiment.neutral ?? 0)])
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(totalSentiment.sentimentBreakdown,id:\.name){sentiment in
                        HStack(alignment: .center, spacing: 10) {
                            Circle()
                                .fill(sentiment.color)
                                .frame(width: 10, height: 10, alignment: .center)
                            MainText(content: sentiment.name, fontSize: 15, color: .gray.opacity(0.5), fontWeight: .medium)
                            MainText(content: "\(sentiment.count)", fontSize: 20, color: .white, fontWeight: .semibold)
                        }
                    }
                    
                }
            }
            
        }
    }
    
    func ColorSelector(value:Float) -> Color{
        return value > 0 ? .green : value < 0 ? .red : .gray
    }
    
    func SentimentSelector(value:Float) -> String{
        return value > 0 ? "Positive" : value < 0 ? "Negative" : "Neutral"
    }
    
    @ViewBuilder func header(w:CGFloat) -> some View{
        if let totalSentiment = self.sentiment.total{
            HStack(alignment: .center, spacing: 10) {
                MainText(content: "Average Sentiment", fontSize: 20, color: .white.opacity(0.85), fontWeight: .medium)
                Spacer()
                MainText(content: "\(self.SentimentSelector(value: totalSentiment.SentimentScore))", fontSize: 22.5, color: self.sentimentTotalColor, fontWeight: .semibold)
            }
            MainSubHeading(heading: "Sentiment Score", subHeading: totalSentiment.SentimentScore.ToDecimals(), headingSize: 15, subHeadingSize: 17.5,headColor:  .white.opacity(0.85), subHeadColor: sentimentTotalColor, headingWeight: .medium, bodyWeight: .semibold)
                .frame(width: w, alignment: .leading)
        }
    }
    
    @ViewBuilder func sentimentTimeline(w:CGFloat) -> some View{
        if let timelineKeys = self.sentiment.TimelineKeysSorted{
            let timeline = timelineKeys.compactMap({self.sentiment.timeline?[$0]})
            let timelineSentimentbySentimentScore = timeline.compactMap({$0.sentiment_score}).sorted(by: {$0 > $1})
            let timelineSentimentValue =  timeline.compactMap({Float($0.SentimentScore)})
            MainText(content: "Sentiment Timeline", fontSize: 20, color: .white.opacity(0.85), fontWeight: .medium)
                .frame(width: w, alignment: .leading)
            CurveChart(data: timelineSentimentValue, interactions: false, size: .init(width: w, height: totalHeight * 0.175), bg: .clear, lineColor: .gray)
            HStack(alignment: .center, spacing: 10) {
                if let highest = timelineSentimentbySentimentScore.first{
                    MainSubHeading(heading: "Highest", subHeading: highest.ToDecimals(),headingSize: 15,subHeadingSize: 17.5,headColor: .gray.opacity(0.75),subHeadColor: self.ColorSelector(value: highest))
                }
                if let lowest = timelineSentimentbySentimentScore.last{
                    MainSubHeading(heading: "Lowest", subHeading: lowest.ToDecimals(),headingSize: 15,subHeadingSize: 17.5,headColor: .gray.opacity(0.75),subHeadColor: self.ColorSelector(value: lowest))
                }
            }.frame(width: w, alignment: .leading)
        }
    }
    
    var body: some View {
        Container(width:self.width,alignment: .center){ w in
            self.header(w: w)
            self.sentimentBreakdown(w: w)
            self.sentimentTimeline(w: w)
        }
    }
}

//struct SentimentsSnapshot_Previews: PreviewProvider {
//
//    static func loadCoinData() -> CrybseAsset?{
//        guard let safeData = readJsonFile(forName: "btcCoinData"),let coinSocialData = CrybseCoinSocialData.parseCoinDataFromData(data: safeData) else {return nil}
//        let asset = CrybseAsset(currency: "BTC")
//        asset.coin = coinSocialData
//        return asset
//    }
//
//    static var previews: some View {
//        if let safeData = SentimentsSnapshot_Previews.loadCoinData(),
//           let safeAsset = CrybseCoinSocialData.parseCoinDataFromData(data: safeData),
//           let safeSentiments = safeAsset.coin?.sentiment
//        {
////            SentimentsSnapshot(sentiment: safeSentiments,width: totalWidth * 0.95,height: totalHeight * 0.5)
//        }else{
//            ProgressView()
//        }
//
//    }
//}
