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
        guard let safeTweet = self.socialHightlights.socialHightlight?.Tweets else {return nil}
        let sortedSafeTweets = safeTweet.sorted(by: {$0.SocialScore > $1.SocialScore})
        return sortedSafeTweets.count > 5 ? Array(sortedSafeTweets[0...4]) : sortedSafeTweets
    }
    
    var reddit:Array<CrybseRedditData>?{
        guard let safeReddit = self.socialHightlights.socialHightlight?.reddit else {return nil}
        return safeReddit.count > 5 ? Array(safeReddit[0...4]) : safeReddit
    }
    
    var news:Array<CrybseNews>?{
        guard let safeNews = self.socialHightlights.socialHightlight?.news else {return nil}
        return safeNews.count > 5 ? Array(safeNews[0...4]) : safeNews
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
            data?.append(contentsOf:safeTweet.count > 3 ? Array(safeTweet[0...2]) : safeTweet)
        }
        
        if let safeReddit = self.socialHightlights.socialHightlight?.Reddit,!safeReddit.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeReddit.count > 3 ? Array(safeReddit[0...2]) : safeReddit)
        }
        
        if let safeNews = self.socialHightlights.socialHightlight?.News, !safeNews.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeNews.count > 3 ? Array(safeNews[0...2]) : safeNews)
        }
        
        if let safeVideo = self.socialHightlights.socialHightlight?.Video, !safeVideo.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf:safeVideo.count > 3 ? Array(safeVideo[0...2]) : safeVideo)
        }
        
        return data
    }
    
    func onTap(idx:Int){
        if self.context.socialHighlightsData == nil{
            self.context.socialHighlightsData = self.socialData
        }
    }

    @ViewBuilder var SocialSummayView:some View{
        if let socialFeed = self.socialData{
            Container(width: self.width,ignoreSides: false) { inner_w in
                
                SocialSection(data: socialFeed, section: .SocialHighlights, viewSection: .constant(.SocialHighlights), width: inner_w) { size, data in
                    self.cardBuilder(data, size)
                        .buttonify {
                            setWithAnimation {
                                if self.context.socialHighlightsData == nil{
                                    self.context.socialHighlightsData = socialFeed
                                }
                            }
                        }
                }

                
            }
            
        }else if self.socialHightlights.loading{
            ProgressView()
                .frame(width:self.cardSize().width,height:self.cardSize().height,alignment:.center)
                .clipContent(clipping: .roundClipping)
        }else{
            Color.clear
        }

    }
    
    var body: some View {
        self.SocialSummayView
            .onAppear(perform: self.onAppear)
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
