//
//  FeedMainPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct CurrencyFeedMainPage: View {
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
            case .feed:
                return "Feed"
            case .reddit:
                return "Reddit"
            case .news:
                return "News"
            case .twitter:
                return "Twitter"
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if self.feedData != nil || (self.feedData != nil && !self.feedData!.isEmpty){
                CurrencyFeedView(heading: self.heading, type: self.type, currency: $currency, data: self.feedData ?? [], viewGen: self.viewBuilder(_:_:), reload: self.reload)
            }else if self.feedData == nil || self.reset{
                ProgressView()
            }
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
        }
    }
    
    func getReddit(){
        CrybseRedditAPI.shared.getRedditPosts(search: self.currency,after: self.next_Page_Token, limit: 20) { data in
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
        CrybseTwitterAPI.shared.getTweetData(endpoint: .tweetsSearch, queryItems: ["entity":self.currency,"language":"en","limit":"20","after":self.next_Page_Token as Any]) { data in
            guard let safeData = data, let safeTweets = CrybseTweets.parseTweetsFromData(data: safeData), let tweets = safeTweets.tweets else {return}
            
            if self.reset{
                self.feedData = tweets
                self.reset.toggle()
            }else{
                if self.feedData == nil{
                    self.feedData = tweets
                }else{
                    self.feedData?.append(contentsOf: tweets)
                }
                
                if let nextToken = safeTweets.next_token{
                    self.next_Page_Token = nextToken
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
                    PostCard(cardType: .Reddit, data: tweet, size: .init(width: width, height: totalHeight * 0.3), isButton: true)
                }
            case .reddit:
                if let reddit = data as? CrybseRedditData{
                    RedditPostCard(width: width, redditPost: reddit)
                }
            case .feed:
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            case .news:
                NewsStandCard(news: data, size: .init(width: width, height: totalHeight * 0.3))
        }
    }

    
}

struct FeedMainPage_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyFeedMainPage(type: .feed)
            .background(Color.mainBGColor)
            .edgesIgnoringSafeArea(.all)
            
            
    }
}
