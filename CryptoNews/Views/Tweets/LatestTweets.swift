//
//  LatestTweets.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/08/2021.
//

import SwiftUI

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
        Container(heading: self.heading, ignoreSides: false, horizontalPadding: 15, verticalPadding: 0, orientation: .vertical) { w in
            self.TweetsFeed(size: .init(width: w, height: totalHeight * 0.3))
                .basicCard()
        }.onAppear(perform: self.onAppear)
    }
}



extension LatestTweets{
    
    var tweets:[AssetNewsData]{
        return self.tweetsAPI.FeedData
    }
    
    func onTapHandler(_ idx:Int){
        if idx >= 0 && idx < self.tweets.count{
            self.context.selectedLink = self.tweets[idx].URL
        }
    }
    
    var topTweets:[AssetNewsData]{
        return Array(self.tweets[0..<5])
    }
    
    var moreTweets:[AssetNewsData]{
        return Array(self.tweets[(self.tweets.count - 5)...])
    }
    
    @ViewBuilder func TweetsFeed(size:CGSize) -> some View{
        if !self.tweetsAPI.FeedData.isEmpty{
            SlideZoomInOutView(data: self.topTweets, timeLimit: 100, size: size, scrollable: true, onTap: self.onTapHandler(_:), viewGen: { (data,size) in
                if let data = data as? AssetNewsData{
                    PostCard(cardType: .Tweet, data: data, size: size,bg: .light, const_size: true,isButton: false)
                }else{
                    Color.clear.frame(width: size.width, height: size.height, alignment: .center)
                }
            })
        }else if self.tweetsAPI.loading{
            ProgressView()
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
}

