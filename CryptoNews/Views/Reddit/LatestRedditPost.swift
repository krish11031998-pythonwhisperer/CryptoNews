//
//  HighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/02/2022.
//

import SwiftUI

struct LatestRedditPost: View {
    @EnvironmentObject var context:ContextData
    @StateObject var redditAPI:CrybseRedditAPI = .init(subReddit: "cryptocurrency")
    var width:CGFloat
    init(width:CGFloat = totalWidth,currencies:[String]){
        self.width = width
    }

    var cardSize:CGSize{
        return .init(width: self.width, height: totalHeight * 0.4)
    }
    
    var posts:CrybseRedditPosts{
        return self.redditAPI.posts.count > 5 ? Array(self.redditAPI.posts[0...4]) : self.redditAPI.posts
    }
    
    @ViewBuilder func selectedView(_ _data:Any, _ w:CGFloat,_ h:CGFloat) -> some View{
        if let safeReddit = _data as? CrybseRedditData{
            RedditPostCard(width: w, size: .init(width: w, height: h), redditPost: safeReddit)
        }
    }
    
    var body: some View {
        Container(heading: "Trending Reddits", headingDivider: true, width: self.width, ignoreSides: false, horizontalPadding: 15,verticalPadding: 0) { w in
            if !self.posts.isEmpty && !self.redditAPI.loading{
                FancyHScroll(data: self.posts,timeLimit:100, size: .init(width: w, height: cardSize.height),scrollable: true) { data, size in
                    self.selectedView(data, size.width,size.height)
                }.basicCard(size: .init(width: w, height: cardSize.height))
            }else if self.redditAPI.loading{
                ProgressView().frame(width: w, height: cardSize.height, alignment: .center)
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
        LatestRedditPost(width:totalWidth - 20,currencies: ["BTC","LTC","XRP"])
            .background(Color.mainBGColor.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
    }
}
