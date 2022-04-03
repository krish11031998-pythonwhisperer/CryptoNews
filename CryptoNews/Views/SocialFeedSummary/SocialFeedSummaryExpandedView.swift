//
//  SocialFeedSummaryExpandedView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/04/2022.
//

import SwiftUI

struct SocialFeedSummaryExpandedView: View {
    
    @EnvironmentObject var context:ContextData
    var data:[Any]
    
    var pageSize:CGSize{
        .init(width: totalWidth, height: totalHeight)
    }
    
    @ViewBuilder func pageBuilder(data:Any,size:CGSize) -> some View{
        if let tweet = data as? CrybseTweet{
            TweetDetailMainView(tweet: tweet,enableOnClose: false)
        }else if let reddit = data as? CrybseRedditData{
            RedditDetailMainView(redditData: reddit,enableClose: false)
        }
    }
    
    func onClose(){
        if self.context.showSocialHighlights{
            self.context.showSocialHighlights.toggle()
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.AppBGColor
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
                .ignoresSafeArea()
            Container(width: totalWidth, ignoreSides: false,horizontalPadding: 0,verticalPadding: 50) { _ in
                ZoomInScrollView(data: self.data, axis: .horizontal, centralizeStart: true, size: self.pageSize, selectedCardSize: self.pageSize) { data, size, _ in
                    self.pageBuilder(data: data, size: size)
                }
            }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        }
        
        
    }
}


struct SocialFeedSummaryExpandedViewTester:View{
    @StateObject var socialHighlightAPI:CrybseSocialHighlightsAPI
    
    init(){
        self._socialHighlightAPI = .init(wrappedValue: .init(assets: ["AVAX","BTC"]))
    }
    
    var body: some View{
        ZStack(alignment: .topLeading) {
            if let socialHighlight = self.socialHighlightAPI.socialHightlight{
                SocialFeedSummaryExpandedView(data: (socialHighlight.Reddit + socialHighlight.Tweets).shuffled())
            }else if self.socialHighlightAPI.loading{
                ProgressView()
            }else{
                MainText(content: "No Data", fontSize: 15, color: .white, fontWeight: .medium)
            }
        }
        .onAppear {
            if self.socialHighlightAPI.socialHightlight == nil{
                self.socialHighlightAPI.getSocialHighlights()
            }
        }
        
    }
}

struct SocialFeedSummaryExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        SocialFeedSummaryExpandedViewTester()
    }
}
