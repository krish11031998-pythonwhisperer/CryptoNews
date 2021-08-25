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
        Container(heading: "Trending Tweets") { w in
            return self.TweetsFeed(size: .init(width: w, height: totalHeight * 0.4))
        }.onAppear(perform: self.onAppear)
    }
}

extension LatestTweets{
    
    func TweetsFeed(size:CGSize) -> AnyView{
        var view = AnyView(Color.clear.frame(width: size.width, height: size.height, alignment: .center).overlay(ProgressView()))
        if !self.tweets.FeedData.isEmpty{
            view = AnyView(AutoTimeCardsView(data: self.tweets.FeedData,size: size, view: { data, size in
                guard let data = data as? AssetNewsData else {return AnyView(Color.clear.frame(width: size.width, height: size.height, alignment: .center))}
                return AnyView(PostCard(cardType: .Tweet, data: data, size: .init(width: size.width, height: size.height), const_size: true))
            }))
        }
        return view
    }
}

