//
//  LatestTweets.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/08/2021.
//

import SwiftUI

extension Date{
    
    func stringDate() -> String{
        var formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter.string(from: self)
    }
}

struct LatestTweets: View {
    @StateObject var tweets:FeedAPI
    var currency:String
    let font_color:Color = .black
    init(currency:String = "all"){
        self.currency = currency
        self._tweets = .init(wrappedValue: .init(currency: currency == "all" ? ["BTC","LTC","DOGE"] : [currency], sources: ["twitter"], type: .Chronological,limit:5))
    }
    
    func onAppear(){
        if self.tweets.FeedData.isEmpty{
            self.tweets.getAssetInfo()
        }
    }
    
    
    
    var body: some View {
        Container(heading: "Latest Tweets") { w in
            return self.TweetsFeed(size: .init(width: w, height: totalHeight * 0.4))
        }.onAppear(perform: self.onAppear)
    }
}

extension LatestTweets{
    
    func TweetsFeed(size:CGSize) -> AnyView{
        var view = AnyView(Color.clear.frame(width: size.width, height: size.height, alignment: .center).overlay(ProgressView()))
        if !self.tweets.FeedData.isEmpty{
            view = AnyView(
                LazyVStack(alignment: .center, spacing: 10){
//                Group{
                    ForEach(Array(self.tweets.FeedData.enumerated()),id:\.offset) { _data in
                        let data = _data.element
                        PostCard(cardType: .Tweet, data: data, size: size)
                    }
                }
            )
        }
        return view
    }
}

