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
    
    init(assets:[String]? = nil,keyword:String = "Cryptocurrency",width:CGFloat){
        self._socialHightlights = .init(wrappedValue: .init(assets: assets ?? []))
        self.width = width
    }
    
    func onAppear(){
        if self.socialHightlights.socialHightlight == nil{
            self.socialHightlights.getSocialHighlights()
        }
        
    }
    
    func cardSize(w:CGFloat? = nil) -> CGSize{
        return .init(width: w ?? self.width, height: totalHeight * 0.3)
    }
    
    @ViewBuilder func cardBuilder(_ data:Any,_ size:CGSize) -> some View{
        if let safeData = data as? CrybseTweet{
            PostCard(cardType: .Tweet, data: safeData, size: size, bg: .light, const_size: true,isButton: false)
        }else if let safeReddit = data as? CrybseRedditData{
            RedditPostCard(width: size.width, size: size, redditPost: safeReddit, const_size: true)
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
        
        return data
    }
    
    func onTap(idx:Int){
//        if let safeTweet = self.socialData?[idx] as? CrybseTweet{
//            if self.context.selectedTweet != safeTweet{
//                self.context.selectedTweet = safeTweet
//            }
//        }else if let safeReddit = self.socialData?[idx] as? CrybseRedditData{
////            if self.context.sele != safeTweet{
////                self.context.selectedTweet = safeTweet
////            }
//        }
//        if let safe
    }

    @ViewBuilder var SocialSummayView:some View{
        if let socialFeed = self.socialData{
            Container(heading: "Social Feed Summary", width: self.width) { inner_w in
                SlideZoomInOutView(data: socialFeed,timeLimit: 10,size: self.cardSize(w: inner_w), scrollable: true,onTap: self.onTap(idx:),viewGen:self.cardBuilder(_:_:))
                    .basicCard()
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
