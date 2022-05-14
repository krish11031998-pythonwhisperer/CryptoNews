//
//  CurrencyFeedView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/10/2021.
//

import SwiftUI

struct CurrencyFeedView<T:View>: View {
    @EnvironmentObject var context:ContextData
    var data:[Any]
    var viewGen:(Any,CGFloat) -> T
    var reload: () -> Void
    var heading:String
    var type:FeedPageType
    @Binding var currency:String
    
    
    init(heading:String,type:FeedPageType,currency:Binding<String>,data:[Any],@ViewBuilder viewGen: @escaping (Any,CGFloat) -> T,reload: @escaping () -> Void){
        self.heading = heading
        self.type = type
        self.data = data
        self._currency = currency
        self.viewGen = viewGen
    
        self.reload = reload
    }
    
    func handleCurrencyChange(_ newCurrency:CrybseCoinSpotPrice?){
        if let sym = newCurrency?.Currency{
            setWithAnimation {
                self.currency = sym
            }
        }
    }
    
    var selectedTweetPost:some View{
 
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showTweet) { w in
            if let safeTweet = self.context.selectedTweet{
                TweetDetailView(tweet: safeTweet, width: w)
            }
        }
    }
    
    var selectedRedditPost:some View{
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showReddit) { w in
            if let safeReddit = self.context.selectedReddit{
                RedditDetailView(reddit: safeReddit, width: w)
            }
        }
    }
    
    var selectedNews:some View{
        CustomNavLinkWithoutLabelWithInnerView(isActive: self.$context.showNews) { w in
            if let safeNews = self.context.selectedNews{
                NewsDetailView(news: safeNews, width: w)
            }
        }
    }
    
    @ViewBuilder var selectedNavLink:some View{
        switch(self.type){
        case .twitter:
            self.selectedTweetPost
        case .reddit:
            self.selectedRedditPost
        case .news:
            self.selectedNews
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: self.heading, width: totalWidth) { w in
//                CurrencyCardView(width: w)
//                    .onPreferenceChange(CurrencySelectorPreference.self, perform: self.handleCurrencyChange(_:))
                CurrencyFeedPage(w: w, symbol: currency, data: self.data, type: self.type, viewBuilder: self.viewGen, reload: self.reload)
                
            }
            
            //NavigationLinks
            self.selectedNavLink
        }
        .ignoresSafeArea(edges: .bottom)
    }
}


extension CurrencyFeedView{
    @ViewBuilder func bg(condition:Bool) -> some View{
        if condition{
            Color.mainBGColor.opacity(0.5)
        }else{
            BlurView(style: .systemThinMaterialDark)
        }
    }
    
}

