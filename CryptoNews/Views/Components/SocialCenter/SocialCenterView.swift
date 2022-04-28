//
//  SocialCenterView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/04/2022.
//

import SwiftUI

struct SectionStylings:Equatable{
    var name:String
    var color:Color
    var icon:UIImage?
    
    
    static var twitter:SectionStylings = .init(name: "Tweets", color: .blue, icon: .init(named: "TwitterIcon"))
    static var reddit:SectionStylings = .init(name: "Reddit", color: .red, icon: .init(named: "RedditIcon"))
    static var news:SectionStylings = .init(name: "News", color: .gray, icon: nil)
    static var socialHighlights:SectionStylings = .init(name: "Social Highlights", color: .init(hex: "#002d69"), icon: nil)
}

enum SocialMediaSummary{
    case Twitter
    case News
    case Reddit
    case SocialHighlights
    case None
    
}

extension SocialMediaSummary{
    func fetchStyling() -> SectionStylings?{
        var result:SectionStylings? = nil
        switch(self){
            case .Twitter:
                result = .twitter
            case .Reddit:
                result = .reddit
            case .News:
                result = .news
        case .SocialHighlights:
                result = .socialHighlights
            case .None:
                result = nil
        }
        return result
    }
}


struct SocialCenterView: View {
    @EnvironmentObject var context:ContextData
    @State var viewSection:SocialMediaSummary = .None
    var tweets:[CrybseTweet]? = nil
    var reddits:[CrybseRedditData]? = nil
    var news:[CrybseNews]? = nil
    var width:CGFloat
    
    
    init(
        tweets:[CrybseTweet]? = nil,
        reddits:[CrybseRedditData]? = nil,
        news:[CrybseNews]? = nil,
        width:CGFloat = totalWidth
    ){
        self.tweets = tweets
        self.reddits = reddits
        self.news = news
        self.width = width
    }
    
    @ViewBuilder func tweetSection(w:CGFloat) -> some View{
        if let safetweets = self.tweets{
            SocialSection(data: safetweets, section: .Twitter,viewSection: $viewSection,width:w,height: totalHeight * 0.125) { size, data in
                if let tweet = data as? CrybseTweet{
                    TweetSnapshot(tweet: tweet, width: size.width,height: size.height)
                        .buttonify(type: .shadow, withBG: false, clipping: .roundClipping) {
                            if self.context.selectedTweet == nil || self.context.selectedTweet?.id != tweet.id {
                                self.context.selectedTweet = tweet
                            }
                        }
                }
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder func newsSection(w:CGFloat) -> some View{
        if let safeNews = self.news{
            SocialSection(data: safeNews, section: .News,viewSection: $viewSection,width:w,height: totalHeight * 0.125) { size, data in
                if let news = data as? CrybseNews{
                    NewsSnapshot(news: news, width: size.width,height: size.height)
                        .buttonify(type: .shadow, withBG: false, clipping: .roundClipping) {
                            if let url = news.news_url,self.context.selectedLink == nil || self.context.selectedLink?.absoluteString != url {
                                self.context.selectedLink = .init(string: url)
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder func redditSection(w:CGFloat) -> some View{
        if let safeReddit = self.reddits{
            SocialSection(data: safeReddit, section: .Reddit, viewSection: $viewSection,width:w,height: totalHeight * 0.125) { size, data in
                if let reddit = data as? CrybseRedditData{
                    RedditSnapshot(redditPost: reddit, width: size.width,height: size.height)
                        .buttonify(type: .shadow, withBG: false, clipping: .roundClipping) {
                            if self.context.selectedReddit == nil || self.context.selectedReddit?.id != reddit.id {
                                self.context.selectedReddit = reddit
                            }
                        }
                }
            }
        }
    }
    
   
    var body: some View {
        Container(width:self.width){ w in
            self.tweetSection(w: w)
            self.redditSection(w: w)
            self.newsSection(w: w)
        }
    }
}


struct SocialSection<T:View>:View{
    @Namespace var animation
    var data:[Any]
    var viewGen:(CGSize,Any) -> T
    var width:CGFloat
    var height:CGFloat
    var section:SocialMediaSummary
    @Binding var viewSection:SocialMediaSummary

    init(
        data:[Any],
        section:SocialMediaSummary,
        viewSection:Binding<SocialMediaSummary>,
        width:CGFloat,
        height:CGFloat = totalHeight * 0.25,
        @ViewBuilder viewGen: @escaping (CGSize,Any) -> T
    ){
        self.data = data
        self.section = section
        self.width = width
        self.height = height
        self._viewSection = viewSection
        self.viewGen = viewGen
        
    }
    
    @ViewBuilder func sectionBuilder(
        data:[Any],
        w:CGFloat,
        section:SocialMediaSummary
    ) -> some View{
        if let styling = section.fetchStyling(){
            Container(width:w,ignoreSides: true,verticalPadding: 0,spacing: 0){ inner_w in
                HStack(alignment: .center, spacing: 10) {
                    MainText(content: styling.name, fontSize: 22.5, color: .white, fontWeight: .medium)
                    Spacer()
                    if let safeIcon = styling.icon{
                        ImageView(img: safeIcon, width: 25, height: 25, contentMode: .fill, alignment: .center)
                    }
                }
                .padding()
                .frame(width: inner_w, alignment: .center)
                .background(styling.color.overlay(BlurView.thinLightBlur).opacity(0.45))
                .onTapGesture {
                    setWithAnimation {
                        if self.viewSection != section{
                            self.viewSection = section
                        }else{
                            self.viewSection = .None
                        }
                    }
                }
                
                if self.viewSection == section{
                    Container(width:inner_w,spacing: 7.5,lazyLoad: true){ _w in
                        ForEach(Array(data.enumerated()), id:\.offset) { _data in
                            if _data.offset != 0{
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.45))
                                    .frame(width: _w, height: 1, alignment: .center)
                            }
                            viewGen(.init(width: _w, height: .zero),_data.element)
                        }
                    }
                }else{
                    ZoomInScrollView(data: data, axis: .horizontal, alignment: .center, centralizeStart: false, lazyLoad: true, size: .init(width: inner_w, height: self.height), selectedCardSize: .init(width: inner_w, height: self.height)) { data, size, _ in
                        Container(width:size.width){ _w in
                            viewGen(.init(width: _w, height: size.height),data)
                                .frame(width: size.width, height: size.height, alignment: .topLeading)
                        }
                    }
                }
            }.basicCard()
                .borderCard(color: styling.color, clipping: .roundClipping)
        }
    }
    
    var body: some View{
        self.sectionBuilder(data: self.data, w: self.width, section: self.section)
    }
    
}

struct SocialCenterView_Previews: PreviewProvider {
    static var previews: some View {
        SocialCenterView()
    }
}
