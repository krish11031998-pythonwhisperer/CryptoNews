//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var context:ContextData
    
    var activeCurrency:Bool{
        return self.context.selectedAsset != nil
    }
    
    var currencies:[String]{
        return self.context.user.user?.watching ?? ["BTC","LTC","ETH","XRP"]
    }
    
    var watchedAsset:[String]{
        return self.context.userAssets.trackedAssets.compactMap({$0.Currency})
    }
    
    
    var mainView:some View{
        CustomNavigationView{
            ScrollView(.vertical,showsIndicators:false){
    //            Spacer().frame(height: 50)
                AllAssetView().asyncContainer()
                Container(width:totalWidth){w in
                    EventViewsTester(width: w)
                }.asyncContainer()
                self.SocialFeedSummary.asyncContainer()
    //            Spacer(minLength: 200)
                
                //NavigationLinks
                
                self.tweetNavLink
                self.newsNavLink
                self.redditNavLink
                self.videoNavLink
                
            }.background(Color.AppBGColor.ignoresSafeArea())
        }
        
        
    }
    
    var body: some View {
        self.mainView
            .background(Color.AppBGColor)
    }
}


extension HomePage{
    
    var pollData:Array<CrybsePollData>{
        Array(1...5).compactMap({CrybsePollData(question: "Question \($0)")})
    }
    
    var assets:[String]{
        return self.context.userAssets.trackedAssets.compactMap({$0.Currency})
    }
    
    var keywords:[String]{
        return self.context.userAssets.trackedAssets.compactMap({$0.CoinData.Name})
    }
    
    @ViewBuilder var SocialFeedSummary:some View{
        if !self.watchedAsset.isEmpty{
            SocialFeedSummaryView(assets: self.assets,keywords: self.keywords, width: totalWidth ,height: totalHeight * 0.35)
        }else{
            SocialFeedSummaryView(width: totalWidth)
        }
    }
    
    @ViewBuilder var pollView:some View{
        Container(heading: "Poll",width: totalWidth,spacing: 40) { w in
            CardFanView(width: w, indices: self.pollData, isScrollable: false) { poll in
                if let safePoll = poll as? CrybsePollData{
                    CrybsePoll(poll: safePoll, width: w, height: 250,alertEventChange: true)
                }
            }
        }.asyncContainer()
    }
    
    var tweetNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showTweet) {
            ScrollView(.vertical, showsIndicators: false) {
                if let safeTweet = self.context.selectedTweet{
                    TweetDetailMainView(tweet: safeTweet, width: totalWidth)
                }
            }
        }
    }
    
    var newsNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showNews) {
            ScrollView(.vertical, showsIndicators: false) {
                if let safeNews = self.context.selectedNews{
                    NewsDetailView(news: safeNews, width: totalWidth)
                }
            }
        }
    }
    
    var redditNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showReddit) {
            ScrollView(.vertical, showsIndicators: false) {
                if let safeReddit = self.context.selectedReddit{
                    RedditDetailView(reddit: safeReddit, width: totalWidth)
                }
            }
        }
    }
    
    var videoNavLink:some View{
        CustomNavLinkWithoutLabel(isActive: self.$context.showVideo) {
            ScrollView(.vertical, showsIndicators: false) {
                if let safeVideo = self.context.selectedVideoData{
                    VideoDetailView(video: safeVideo, width: totalWidth)
                }
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    @StateObject static var context:ContextData = .init()
    static var previews: some View {
        HomePage()
            .environmentObject(HomePage_Previews.context)
            .background(Color.mainBGColor.ignoresSafeArea())
    }
}
