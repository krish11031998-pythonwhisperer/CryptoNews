//
//  LatestTweets.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/08/2021.
//

import SwiftUI

struct LatestTweets: View {
    @EnvironmentObject var context:ContextData
//    @StateObject var tweetsAPI:FeedAPI
    @StateObject var tweetsAPI:CrybseTwitterAPI
    let font_color:Color = .black
    var heading:String? = nil
    init(header:String? = nil,currencies:[String] = ["BTC","LTC","DOGE"] ,type:FeedType = .Chronological, limit:Int = 5){
        self.heading = header
//        self._tweetsAPI = .init(wrappedValue: .init(currency: currencies, sources: ["twitter"], type: type,limit:limit))
        self._tweetsAPI = .init(wrappedValue: .init(endpoint: .tweetsSearch, queries: [.init(name: "entity", value: currencies.joined(separator: ",")),.init(name: "language", value: "en")]))
//        self._tweetsAPI = .init(wrappedValue: .init(endpoint: <#T##CrybseTwitterEndpoints#>, queries: <#T##[URLQueryItem]?#>))
    }
    
    func onAppear(){
        if self.tweetsAPI.tweets == nil {
            self.tweetsAPI.getTweets()
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
    
    var tweets:CrybseTweets{
        return self.tweetsAPI.tweets ?? []
    }
    
    func onTapHandler(_ idx:Int){
//        if idx >= 0 && idx < self.tweets.count{
//            self.context.selectedLink = self.tweets[idx].URL
//        }
    }
    
    var topTweets:CrybseTweets{
        return Array(self.tweets[0..<5])
    }
    
    var moreTweets:CrybseTweets{
        return Array(self.tweets[(self.tweets.count - 5)...])
    }
    
    @ViewBuilder func TweetsFeed(size:CGSize) -> some View{
        if let tweets = self.tweetsAPI.tweets, !tweets.isEmpty{
            SlideZoomInOutView(data: tweets, timeLimit: 100, size: size, scrollable: true, onTap: self.onTapHandler(_:), viewGen: { (data,size) in
                if let data = data as? CrybseTweet{
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

