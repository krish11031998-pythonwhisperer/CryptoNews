//
//  HighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/02/2022.
//

import SwiftUI

struct HighlightView: View {
    @EnvironmentObject var context:ContextData
//    @StateObject var feedAPI:FeedAPI
    @StateObject var redditAPI:CrybseRedditAPI = .init(subReddit: "cryptocurrency")
    var width:CGFloat
    init(width:CGFloat = totalWidth,currencies:[String]){
        self.width = width
    }

    var cardSize:CGSize{
        return .init(width: self.width, height: totalHeight * 0.475)
    }
    
    var posts:CrybseRedditPosts{
        return self.redditAPI.posts.count > 5 ? Array(self.redditAPI.posts[0...4]) : self.redditAPI.posts
    }
    
    @ViewBuilder func selectedView(_ _data:Any, _ w:CGFloat) -> some View{
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
        }else if let safeReddit = _data as? CrybseRedditData{
            RedditPostCard(width: w, size: .init(width: w, height: totalHeight * 0.25), redditPost: safeReddit)
        }
    }
    
    var body: some View {
        Container(heading: "Social Highlights", headingDivider: true, width: self.width, ignoreSides: false) { w in
            if !self.posts.isEmpty && !self.redditAPI.loading{
                CardFanView(width: w,indices: self.posts) { _data in
                    self.selectedView(_data, w)
                }.padding(.vertical,25)
            }else if self.redditAPI.loading{
                ProgressView()
            }else{
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            }
            
        }.onAppear {
            self.redditAPI.getRedditPosts()
        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(width:totalWidth - 20,currencies: ["BTC","LTC","XRP"])
            .background(Color.mainBGColor.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
    }
}
