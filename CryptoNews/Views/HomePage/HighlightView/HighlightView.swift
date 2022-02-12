//
//  HighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/02/2022.
//

import SwiftUI

struct HighlightView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var feedAPI:FeedAPI
    var width:CGFloat
    init(width:CGFloat = totalWidth,currencies:[String]){
        self.width = width
        self._feedAPI = .init(wrappedValue: .init(currency: currencies, sources: ["twitter","reddit","news"], type: .Chronological, limit: 50, page: 0))
    }

    var cardSize:CGSize{
        return .init(width: self.width, height: totalHeight * 0.475)
    }
    
    var posts:[AssetNewsData]{
        return self.feedAPI.FeedData.count > 10 ? Array(self.feedAPI.FeedData[0...9]) : self.feedAPI.FeedData
    }
    
    var body: some View {
        Container(heading: "Social Highlights", headingDivider: true, width: self.width, ignoreSides: false) { w in
            if !self.posts.isEmpty && !self.feedAPI.loading{
                CardFanView(width: w,indices: self.posts) { _data in
                    if let data = _data as? AssetNewsData{
                        if let _ = data.twitter_screen_name{
                            PostCard(cardType: .Tweet, data: data, size: .init(width: w, height: cardSize.height), const_size: true, isButton: true)
                        }else if let _ = data.subreddit{
                            PostCard(cardType: .Reddit, data: data, size: .init(width: w, height: cardSize.height), const_size: true, isButton: true)
                        }else{
                            NewsCard(news: data, size: .init(width: w, height: cardSize.height))
                                .buttonify {
                                    if self.context.selectedNews?.id != data.id{
                                        self.context.selectedNews = data
                                    }
                                }
                        }
                    }
                }.padding(.vertical,25)
            }else if self.feedAPI.loading{
                ProgressView()
            }else{
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            }
            
        }.onAppear(perform: self.feedAPI.getAssetInfo)
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(width:totalWidth - 20,currencies: ["BTC","LTC","XRP"])
            .background(Color.mainBGColor.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
    }
}
