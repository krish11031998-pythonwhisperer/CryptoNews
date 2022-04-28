//
//  TweetSnapshot.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/04/2022.
//

import SwiftUI

struct TweetSnapshot: View {
    var tweet:CrybseTweet
    var width:CGFloat
    var height:CGFloat
    
    
    init(tweet:CrybseTweet,width:CGFloat = totalWidth,height:CGFloat? = nil){
        self.tweet = tweet
        self.width = width
        self.height = height ?? .zero
    }
    
    @ViewBuilder func headerView(w:CGFloat) -> some View{
        if let user = self.tweet.user{
            Container(width:w,ignoreSides:true,verticalPadding: 2.5, orientation: .horizontal){ _ in
                MainText(content: "@" + (user.username ?? "no username"), fontSize: 15, color: .white, fontWeight: .medium)
                Spacer()
                SystemButton(b_name: "arrow.2.squarepath", b_content: "\(self.tweet.publicMetric?.retweet_count ?? 0)", color: .blue, haveBG: false, bgcolor: .white, alignment: .horizontal, borderedBG: false) {
                    print("Clicked on Retweet")
                }
                SystemButton(b_name: "heart", b_content: "\(self.tweet.publicMetric?.like_count ?? 0)", color: .red, haveBG: false, bgcolor: .white, alignment: .horizontal, borderedBG: false) {
                    print("Clicked on Retweet")
                }
            }
        }
    }
    
    
    
    var body: some View {
        Container(width:self.width,horizontalPadding: 7.5,verticalPadding: 7.5){inner_w in
            self.headerView(w: inner_w)
            if let text = self.tweet.text{
                MainText(content: text, fontSize: 15, color: .white.opacity(0.75), fontWeight: .medium)
            }
            if self.height != .zero{
                Spacer(minLength: 0)
            }
        }.basicCard(size: self.height == .zero ? .zero : .init(width: self.width, height: self.height), background: Color.clear.anyViewWrapper())
    }
}

//struct TweetSnapshot_Previews: PreviewProvider {
//    static var previews: some View {
//        TweetSnapshot()
//    }
//}
