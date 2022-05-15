//
//  FeedMainPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct CurrencyFeedMainPage: View {
    @EnvironmentObject var contextData:ContextData
    @State var feedData:[Any]? = nil
    @State var currency:String = "BTC"
    @State var next_Page_Token:String? = nil
    @State var reset:Bool = false
    @State var type:FeedPageType = .twitter

    var heading:String{
        switch self.type{
            case .reddit:
                return "Reddit"
            case .news:
                return "News"
            case .twitter:
                return "Twitter"
        }
    }
    
    @ViewBuilder var feedView:some View{
        if let safeFeedData = self.feedData, !safeFeedData.isEmpty{
            CurrencyFeedView(heading: self.heading, type: self.type, currency: $currency, data: self.feedData ?? [], viewGen: self.viewBuilder(_:_:), reload: self.reload)
        }else if self.feedData == nil || self.reset{
            ProgressView()
        }
    }
    
    func sectionSelectorElements(type:FeedPageType) -> (String,String,FeedPageType){
        var sectionSelector:(String,String,FeedPageType)
        switch(type){
        case .twitter:
            sectionSelector = ("Twitter","TwitterIcon",.twitter)
        case .reddit:
            sectionSelector = ("Reddit","RedditIcon",.reddit)
        case .news:
            sectionSelector = ("News","📰",.news)
        }
        return sectionSelector
        
    }
    
    @ViewBuilder func sectionHeader(isHeading:Bool = false,type:FeedPageType) -> some View{
        let sectionSelectorElements = self.sectionSelectorElements(type: type)
        if isHeading{
            MainText(content: sectionSelectorElements.0, fontSize: 30, color: .white, fontWeight: .medium)
                .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                    if sectionSelectorElements.2 == .news{
                        MainText(content: "📰", fontSize: 30)
                    }else{
                        ImageView(img: .init(named: sectionSelectorElements.2 == .twitter ? "TwitterIcon" : "RedditIcon"), width: 40 , height: 40, contentMode: .fill, alignment:.center)
                    }
                }
            
        }else{
            MainText(content: sectionSelectorElements.0, fontSize: 15, color: self.type == sectionSelectorElements.2 ? .black : .white, fontWeight: .medium)
                .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .left) {
                    if sectionSelectorElements.2 == .news{
                        MainText(content: "📰", fontSize: 15)
                    }else{
                        ImageView(img: .init(named: sectionSelectorElements.1), width: 20 , height: 20, contentMode: .fill, alignment:.center )
                    }
                }
                .padding(10)
                .basicCard(background: (self.type == sectionSelectorElements.2 ? Color.white : Color.clear).anyViewWrapper())
                .borderCard(color: self.type == sectionSelectorElements.2 ? Color.black : Color.white, clipping: .roundClipping)
        }
    }
    
    @ViewBuilder func sectionSelector(w:CGFloat) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                self.sectionHeader(type: .twitter)
                    .buttonify {
                        if self.type != .twitter{
                            self.type = .twitter
                        }
                    }
                
                self.sectionHeader(type: .reddit)
                    .buttonify {
                        if self.type != .reddit{
                            self.type = .reddit
                        }
                    }
                
                self.sectionHeader(type: .news)
                    .buttonify {
                        if self.type != .news{
                            self.type = .news
                        }
                    }
            }.padding(2)
        }.frame(width: w, alignment: .leading)
    }
    
    var body: some View {
        CustomNavigationView {
            StylisticHeaderView(baseNavBarHeight:totalHeight * 0.15,minimumNavBarHeight: totalHeight * 0.1){ size in
                Container(heading: "Social Feed", headingColor: .white, headingDivider: false, headingSize: 20, width: size.width, ignoreSides: true, horizontalPadding: 0, verticalPadding: 0,spacing: 0) { w in
                    self.sectionSelector(w: w)
                }.frame(width: size.width, height: size.height, alignment: .center)
            } innerView: {
                self.feedView
            } customNavBarView: { size in
                self.sectionHeader(isHeading: true, type: self.type)
                    .anyViewWrapper()
            }

            self.feedView
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
                .background(Color.AppBGColor.ignoresSafeArea())
                
        }
        .onAppear(perform: self.fetchData)
        .onChange(of: self.type, perform: { newValue in
            if self.feedData != nil{
                self.feedData = nil
            }
            self.fetchData()
        })
    }
}


extension CurrencyFeedMainPage{
    
    func fetchData(){
        if self.type == .reddit{
            self.getReddit()
        }else if self.type == .twitter{
            self.getTweets()
        }else if self.type == .news{
            self.getNews()
        }
    }
    
    func getNews(){
        CrybseNewsAPI.shared.getNews { data in
            guard let safeData = data, let safeNews = CrybseNewsList.parseNewsDataList(data: safeData) else {return}
            if self.reset{
                self.feedData = safeNews
                self.reset.toggle()
            }else{
                if self.feedData == nil{
                    self.feedData = safeNews
                }else{
                    self.feedData?.append(contentsOf: safeNews)
                }
            }
        }
    }
    
    func getReddit(){
        CrybseRedditAPI.shared.getRedditPosts(limit: 20) { data in
            guard let safeData = data,let safeNewRedditPosts = CrybseRedditPosts.parseFromData(data: safeData) else {return}
            
            if self.reset{
                self.feedData = safeNewRedditPosts
                self.reset.toggle()
            }else{
                if self.feedData == nil{
                    self.feedData = safeNewRedditPosts
                }else{
                    self.feedData?.append(contentsOf: safeNewRedditPosts)
                }
                
                if let redditNextToken = safeNewRedditPosts.last?.id{
                    self.next_Page_Token = redditNextToken
                }
            }
        }
    }
    
    
    func getTweets(){
        CrybseTwitterAPI.shared.getTweetData(endpoint: .tweets) { data in
            guard let safeData = data, let safeTweets = CrybseTweet.parseTweetsFromData(data: safeData) else {return}
            
            if self.reset{
                self.feedData = safeTweets
                self.reset.toggle()
            }else{
                if self.feedData == nil{
                    self.feedData = safeTweets
                }else{
                    self.feedData?.append(contentsOf: safeTweets)
                }
    
            }
            
        }
    }
    
    func reload(){
        print("(DEBUG) Reload called!")
    }
    
    
    @ViewBuilder func viewBuilder(_ data:Any,_ width:CGFloat) -> some View{
        switch(self.type){
        case .twitter:
            if let tweet = data as? CrybseTweet{
                TwitterPostCard(cardType: .Reddit, data: tweet, size: .init(width: width, height: totalHeight * 0.3), isButton: true)
            }
        case .reddit:
            if let reddit = data as? CrybseRedditData{
                RedditPostCard(width: width, redditPost: reddit)
            }
        case .news:
            if let news = data as? CrybseNews{
                NewsStandCard(news: news, size: .init(width: width, height: totalHeight * 0.25))
            }
        }
    }

    
}

struct FeedMainPage_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyFeedMainPage(type: .reddit)
            .background(Color.AppBGColor)
            .edgesIgnoringSafeArea(.all)
    }
}
