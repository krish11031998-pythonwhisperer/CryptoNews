//
//  SocialFeedSummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/03/2022.
//

import SwiftUI

struct SocialFeedSummaryView: View {
    @EnvironmentObject var context:ContextData
    @State var idx:Int = .zero
    @StateObject var socialHightlights:CrybseSocialHighlightsAPI
    var width:CGFloat
    var height:CGFloat
    
    init(
        assets:[String]? = nil,
        keyword:String = "Cryptocurrency",
        width:CGFloat,
        height:CGFloat = totalHeight  * 0.4
    ){
        self._socialHightlights = .init(wrappedValue: .init(assets: assets ?? []))
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
        if let safeData = data as? CrybseTweet{
            PostCard(cardType: .Tweet, data: safeData, size: size, bg: .light, const_size: true,isButton: false)
        }else if let safeReddit = data as? CrybseRedditData{
            RedditPostCard(width: size.width, size: size, redditPost: safeReddit, const_size: true,isButton: false)
        }else if let safeNews = data as? CrybseNews{
            if safeNews.type?.lowercased() == "video",let safeVideoId = safeNews.VideoID{
                VideoCard(data: .init(id: .init(videoId: safeVideoId,title: safeNews.title),imgURL: safeNews.image_url), size: size,smallCard: true)
            }else{
                NewsCard(news: safeNews, size: size)
            }
            
        }
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
            data?.append(contentsOf: safeReddit)
        }
        
        if let safeNews = self.socialHightlights.socialHightlight?.News, !safeNews.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf: safeNews)
        }
        
        if let safeVideo = self.socialHightlights.socialHightlight?.Video, !safeVideo.isEmpty{
            if data == nil{
                data = []
            }
            data?.append(contentsOf: safeVideo)
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
            Container(heading: "Trending Social", width: self.width) { inner_w in
                ZoomInScrollView(data: socialFeed, axis: .horizontal, centralizeStart: true, size: self.cardSize(w: inner_w * 0.75),selectedCardSize: self.cardSize(w: inner_w * 0.75)) { data, size, _ in
                    self.cardBuilder(data, size)
                        .slideZoomInOut(cardSize: size)
                        .buttonify {
                            if self.context.socialHighlightsData == nil{
                                self.context.socialHighlightsData = self.socialData
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
