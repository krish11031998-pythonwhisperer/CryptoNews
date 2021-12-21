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
    @EnvironmentObject var context:ContextData
    @StateObject var tweetsAPI:FeedAPI
    let font_color:Color = .black
    var heading:String? = nil
    init(header:String? = nil,currencies:[String] = ["BTC","LTC","DOGE"] ,type:FeedType = .Chronological, limit:Int = 5){
        self.heading = header
        self._tweetsAPI = .init(wrappedValue: .init(currency: currencies, sources: ["twitter"], type: type,limit:limit))
    }
    
    func onAppear(){
        if self.tweetsAPI.FeedData.isEmpty{
            self.tweetsAPI.getAssetInfo()
        }
    }
    
    
    
    var body: some View {
        Container(heading:self.heading,ignoreSides: true) { w in
            self.TweetsFeed(size: .init(width: w, height: totalHeight * 0.4))
            if !self.tweets.isEmpty{
                ForEach(Array(self.moreTweets.enumerated()), id:\.offset) { _tweet in
                    PostCard(cardType: .Tweet, data: _tweet.element, size: .init(width: w, height: totalHeight * 0.4), bg: .dark, const_size: false, isButton: true)
                }
                .frame(width: totalWidth, alignment: .center)
            }
        }.onAppear(perform: self.onAppear)
        
    }
}



extension LatestTweets{
    
    var tweets:[AssetNewsData]{
        return self.tweetsAPI.FeedData
    }
    
    func onTapHandler(_ idx:Int){
        if idx >= 0 && idx < self.tweets.count{
            withAnimation(.easeInOut) {
                self.context.selectedNews = self.tweets[idx]
            }
        }
    }
    var topTweets:[AssetNewsData]{
        return Array(self.tweets[0..<(self.tweets.count - 5)])
    }
    
    var moreTweets:[AssetNewsData]{
        return Array(self.tweets[(self.tweets.count - 5)...])
    }
    
    @ViewBuilder func TweetsFeed(size:CGSize) -> some View{
        if !self.tweetsAPI.FeedData.isEmpty{
            FancyHScroll(data: self.topTweets, timeLimit: 100, size: size, scrollable: true, onTap: self.onTapHandler(_:), viewGen: { data in
                if let data = data as? AssetNewsData{
                    PostCard(cardType: .Tweet, data: data, size: .init(width: size.width, height: size.height),bg: .light, const_size: true,isButton: false)
                }else{
                    Color.clear.frame(width: size.width, height: size.height, alignment: .center)
                }
            })
        }else if self.tweetsAPI.loading{
            Color.clear.frame(width: size.width, height: size.height, alignment: .center).overlay(ProgressView())
        }
    }
}

