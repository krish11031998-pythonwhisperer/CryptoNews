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
                AllAssetView().asyncContainer()
                Container(width:totalWidth){w in
                    EventViewsTester(width: w)
                }.asyncContainer()
                self.SocialFeedSummary.asyncContainer()
                    .padding(.bottom,50)
                
                //NavigationLinks
                
                self.socialHighlightNavLink
                self.tweetNavLink
                self.newsNavLink
                self.redditNavLink
                self.videoNavLink
                
            }.background(Color.AppBGColor)
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
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showTweet) {w in
            if let safeTweet = self.context.selectedTweet{
                TweetDetailView(tweet: safeTweet, width: w)
            }
        }
    }
    
    var newsNavLink:some View{
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showNews) { w in
            if let safeNews = self.context.selectedNews{
                NewsDetailView(news: safeNews, width: w)
            }
        }
    }
    
    var redditNavLink:some View{
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showReddit) { w in
            if let safeReddit = self.context.selectedReddit{
                RedditDetailView(reddit: safeReddit, width: w)
            }
        }
    }
    
    var videoNavLink:some View{
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showVideo) { w in
            if let safeVideo = self.context.selectedVideoData{
                VideoDetailView(video: safeVideo, width: w)
            }
        }
    }
    
    var socialHighlightNavLink:some View{
        CustomNavLinkWithoutLabelWithInnerView(ignoreSide: true, isActive: self.$context.showSocialHighlights) { w in
            if let socialHighlights = self.context.socialHighlightsData as? [Any]{
                SocialFeedSummaryExpandedView(data: socialHighlights)
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
