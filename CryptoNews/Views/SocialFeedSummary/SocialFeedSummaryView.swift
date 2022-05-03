//
//  SocialFeedSummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/03/2022.
//

import SwiftUI
struct SocialFeedSummaryView: View {
    @EnvironmentObject var context:ContextData
    @State var viewSection:SocialMediaSummary = .None
    @Namespace var animation
    @State var idx:Int = .zero
    @StateObject var socialHightlights:CrybseSocialHighlightsAPI
    var width:CGFloat
    var height:CGFloat
    
    init(
        assets:[String]? = nil,
        keywords:[String]? = nil,
        keyword:String = "Cryptocurrency",
        width:CGFloat,
        height:CGFloat = totalHeight  * 0.4
    ){
        self._socialHightlights = .init(wrappedValue: .init(assets: assets ?? [],keywords:keywords ?? []))
        self.width = width
        self.height = height
    }
    
    func onAppear(){
        if self.socialHightlights.socialHightlight == nil{
            self.socialHightlights.getSocialHighlights()
        }
        
    }
    
    func cardSize(w:CGFloat? = nil) -> CGSize{
        return .init(width: w ?? self.width, height: self.height)
    }
    
    @ViewBuilder func cardBuilder(_ data:Any,_ size:CGSize) -> some View{
        if let news = data as? CrybseNews{
            NewsSnapshot(news: news, width: size.width, height: size.height)
        }else if let tweet = data as? CrybseTweet{
            TweetSnapshot(tweet: tweet, width: size.width, height: size.height)
        }else if let reddit = data as? CrybseRedditData{
            RedditSnapshot(redditPost: reddit, width: size.width, height: size.height)
        }
    }
    
    var tweets:Array<CrybseTweet>?{
        return self.socialHightlights.socialHightlight?.Tweets
    }
    
    var reddit:Array<CrybseRedditData>?{
        return self.socialHightlights.socialHightlight?.Reddit
    }
    
    var news:Array<CrybseNews>?{
        return self.socialHightlights.socialHightlight?.News
    }
    
    var videos:Array<CrybseNews>?{
        return self.socialHightlights.socialHightlight?.Video
    }
    
    var socialData:[Any]?{
        var data:[Any]? = nil
        if let safeTweet = self.socialHightlights.socialHightlight?.Tweets,!safeTweet.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeTweet)
        }
        
        if let safeReddit = self.socialHightlights.socialHightlight?.Reddit,!safeReddit.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeReddit)
        }
        
        if let safeNews = self.socialHightlights.socialHightlight?.News, !safeNews.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeNews)
        }
        
        if let safeVideo = self.socialHightlights.socialHightlight?.Video, !safeVideo.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeVideo)
        }
        
        return data
    }
    
    func onTap(idx:Int){
        if self.context.socialHighlightsData == nil{
            self.context.socialHighlightsData = self.socialData
        }
    }

    
    var body: some View {        Container(width:self.width,ignoreSides:false,verticalPadding: 0){ w in
            SocialHighlightFeedView(width: w,video: self.videos, news: self.news, tweet: self.tweets, reddit: self.reddit)
                .onAppear(perform: self.onAppear)
            if let safeSocialData = self.socialData,safeSocialData.count > 0{
                MainText(content: "View More", fontSize: 15, color: .white, fontWeight: .medium)
                    .textBubble(color: .black, clipping: .roundClipping, verticalPadding: 10, horizontalPadding: 15)
                    .padding(.top,25)
                    .buttonify {
                        if self.context.socialHighlightsData == nil,let socialData = self.socialData{
                            self.context.socialHighlightsData = socialData
                        }
                    }
            }
            
        }
    }
}

struct SocialFeedSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            SocialFeedSummaryView(assets: ["AVAX","DOT","LTC"], width: totalWidth - 30)
            Spacer()
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.AppBGColor)
        .ignoresSafeArea()
    }
}
