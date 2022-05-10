//
//  SocialHighlightFeedView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/05/2022.
//

import SwiftUI

enum SocialHighlightSection{
    case video
    case news
    case tweet
    case reddit
    case none
}


struct SocialHighlightFeedView: View {
    @EnvironmentObject var context:ContextData
    var width:CGFloat
    var video:[CrybseNews]?
    var news:[CrybseNews]?
    var tweet:[CrybseTweet]?
    var reddit:[CrybseRedditData]?
    @State var section:SocialHighlightSection = .tweet
    
    init(
        width:CGFloat = totalWidth,
        video:[CrybseNews]?,
         news:[CrybseNews]?,
         tweet:[CrybseTweet]?,
         reddit:[CrybseRedditData]?
    ){
        self.width = width
        self.video = video
        self.news = news
        self.tweet = tweet
        self.reddit = reddit
    }
    
    
    @ViewBuilder func cardBuilder(_ data:Any,_ size:CGSize) -> some View{
        if let news = data as? CrybseNews{
            if news.type?.lowercased() == "video"{
                VideoSnapshot(videoData: news, width: size.width, height: size.height * 1.5)
                    .buttonify {
                        if self.context.selectedVideoData?.date != news.date{
                            self.context.selectedVideoData = news
                        }
                    }
            }else{
                NewsSnapshot(news: news, width: size.width, height: size.height)
                    .buttonify {
                        if self.context.selectedNews?.date != news.date{
                            self.context.selectedNews = news
                        }
                    }
            }
            
        }else if let tweet = data as? CrybseTweet{
            TweetSnapshot(tweet: tweet, width: size.width, height: size.height)
                .buttonify {
                    if self.context.selectedTweet != tweet{
                        self.context.selectedTweet = tweet
                    }
                }
        }else if let reddit = data as? CrybseRedditData{
            RedditSnapshot(redditPost: reddit, width: size.width, height: size.height)
                .buttonify {
                    if self.context.selectedReddit != reddit{
                        self.context.selectedReddit = reddit
                    }
                }
        }
    }
    
    @ViewBuilder func sectionSelector(w:CGFloat) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                MainText(content: "Tweet", fontSize: 15, color: self.section == .tweet ? .black : .white, fontWeight: .medium)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                        ImageView(img: .init(named: "TwitterIcon"), width: 20 , height: 20, contentMode: .fill, alignment:.center )
                    }
                    .padding(10)
                    .basicCard(background: (self.section == .tweet ? Color.white : Color.clear).anyViewWrapper())
                    .borderCard(color: self.section == .tweet ? Color.black : Color.white, clipping: .roundClipping)
                    .buttonify {
                        if self.section != .tweet{
                            self.section = .tweet
                        }
                    }
                
                MainText(content: "Reddit", fontSize: 15, color: self.section == .reddit ? .black : .white, fontWeight: .medium)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                        ImageView(img: .init(named: "RedditIcon"), width: 20 , height: 20, contentMode: .fill, alignment:.center )
                    }
                    .padding(10)
                    .basicCard(background: (self.section == .reddit ? Color.white : Color.clear).anyViewWrapper())
                    .borderCard(color: self.section == .reddit ? Color.black : Color.white, clipping: .roundClipping)
                    .buttonify {
                        if self.section != .reddit{
                            self.section = .reddit
                        }
                    }
                
                MainText(content: "News", fontSize: 15, color: self.section == .news ? .black : .white, fontWeight: .medium)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                        MainText(content: "📰", fontSize: 15)
                    }
                    .padding(10)
                    .basicCard(background: (self.section == .news ? Color.white : Color.clear).anyViewWrapper())
                    .borderCard(color: self.section == .news ? Color.black : Color.white, clipping: .roundClipping)
                    .buttonify {
                        if self.section != .news{
                            self.section = .news
                        }
                    }
                
                MainText(content: "Videos", fontSize: 15, color: self.section == .video ? .black : .white, fontWeight: .medium)
                    .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                        ImageView(img: .init(named: "YoutubeIcon"), width: 20 , height: 20, contentMode: .fill, alignment:.center )
                    }
                    .padding(10)
                    .basicCard(background: (self.section == .video ? Color.white : Color.clear).anyViewWrapper())
                    .borderCard(color: self.section == .video ? Color.black : Color.white, clipping: .roundClipping)
                    .buttonify {
                        if self.section != .video{
                            self.section = .video
                        }
                    }
            }.padding(2)
        }.frame(width: w, alignment: .leading)
    }
    
    var Video:[CrybseNews]{
        return self.video ?? []
    }
    
    var Reddit:[CrybseRedditData]{
        return self.reddit ?? []
    }
    
    var News:[CrybseNews]{
        return self.news ?? []
    }
    
    var Tweet:[CrybseTweet]{
        return self.tweet ?? []
    }
    
    var socialData:[Any]?{
        switch(self.section){
            case .none:
            return (self.Video.limitData(limit: 5) + self.Reddit.limitData(limit: 5) + self.News.limitData(limit: 5) + self.Tweet.limitData(limit: 5)).sorted { ElOne, ElTwo in
                func DateRetriever(data:Any) -> Date{
                    if let safeTweet = data as? CrybseTweet{
                        return safeTweet.CreatedAtDate
                    }else if let safeReddit = data as? CrybseRedditData{
                        return safeReddit.CreatedAtDate
                    }else if let safeNews = data as? CrybseNews{
                        return safeNews.CreatedAtDate
                    }else{
                        return Date()
                    }
                }
                
                return DateRetriever(data: ElOne) < DateRetriever(data: ElTwo)
            }
            case .news:
                return self.News.limitData(limit: 5).sorted(by: {$0.CreatedAtDate < $1.CreatedAtDate})
            case .tweet:
                return self.Tweet.limitData(limit: 5).sorted(by: {$0.CreatedAtDate < $1.CreatedAtDate})
            case .reddit:
                return self.Reddit.limitData(limit: 5).sorted(by: {$0.CreatedAtDate < $1.CreatedAtDate})
            case .video:
                return self.Video.limitData(limit: 5).sorted(by: {$0.CreatedAtDate < $1.CreatedAtDate})
        }
        
    }
    
    var allSocialData:[Any]?{
        self.Video + self.Reddit + self.News + self.Tweet
    }
    
    var body: some View {
        if let safeData = self.socialData{
            Container(heading: "Social Highlights", headingColor: .white, headingDivider: false, headingSize: 30, width: self.width,horizontalPadding: 15,lazyLoad: false) { inner_w in
                self.sectionSelector(w: inner_w)
                ForEach(Array(safeData.enumerated()), id:\.offset) { _data in
                    if _data.offset != 0{
                        Rectangle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: inner_w, height: 1, alignment: .center)
                    }
                    self.cardBuilder(_data.element, .init(width: inner_w, height: totalHeight * 0.25))
                }
            }
            .basicCard(background: Color.clear.anyViewWrapper())
            .borderCard(color: .white, clipping: .roundClipping)
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
        
    }
}

struct SocialHighlightFeedView_Previews: PreviewProvider {
    
    static func loadFiles() -> CrybseSocialHighlights?{
        if let safeData = readJsonFile(forName: "socialHighlights"){
            if let safeSocialHighlights = CrybseSocialHighlightResponse.parseHighlightsFromData(data: safeData){
                return safeSocialHighlights
            }
        }else{
            print("JSON file with the name : socialHighlights is not available")
        }
        return nil
    }
    
    static var previews: some View {
        if let safeSocialHighlights = SocialHighlightFeedView_Previews.loadFiles(){
            ScrollView(.vertical, showsIndicators: false) {
                SocialHighlightFeedView(video: safeSocialHighlights.videos, news: safeSocialHighlights.news, tweet: safeSocialHighlights.tweets, reddit: safeSocialHighlights.reddit)
                    .padding(.top,50)
            }
            .frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
            .background(Color.AppBGColor)
            .ignoresSafeArea()
                
        }else{
            MainText(content: "JSON file with the name : socialHighlights is not available", fontSize: 15,fontWeight: .medium)
        }
        
    }
}
