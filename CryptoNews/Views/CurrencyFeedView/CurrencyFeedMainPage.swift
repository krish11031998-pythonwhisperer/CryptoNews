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
    var type:FeedPageType = .twitter
    
    init(type:FeedPageType){
        self.type = type
    }

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
        if self.feedData != nil || (self.feedData != nil && !self.feedData!.isEmpty){
            CurrencyFeedView(heading: self.heading, type: self.type, currency: $currency, data: self.feedData ?? [], viewGen: self.viewBuilder(_:_:), reload: self.reload)
        }else if self.feedData == nil || self.reset{
            ProgressView()
        }
    }
    
    var body: some View {
        CustomNavigationView {
            self.feedView
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
                .background(Color.AppBGColor.ignoresSafeArea())
                
        }
                .onAppear(perform: self.onAppear)
        .onChange(of: self.currency) { newCurr in
            self.reset = true
            self.next_Page_Token = nil
            self.fetchData()
        }
    }
}


extension CurrencyFeedMainPage{
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.fetchData()
        }
    }
    
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
            NewsStandCard(news: data, size: .init(width: width, height: totalHeight * 0.3))
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
