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
            Container(width:w,ignoreSides:true,verticalPadding: 0, orientation: .horizontal,alignment: .top){ _ in
                MainSubHeading(heading: "@" + (user.username ?? "no username"), subHeading: tweet.CreatedAt, headingSize: 20, subHeadingSize: 13, headColor: .white, subHeadColor: .gray, headingWeight: .medium, bodyWeight: .medium, spacing: 5, alignment: .topLeading)
                Spacer()
                if let imgURL = self.tweet.user?.profile_image_url{
                    ImageView(url: imgURL, width: 35, height: 35, contentMode: .fill, alignment: .center,clipping: .circleClipping)
                }
            }
        }
    }
    
    
    
    var body: some View {
        Container(width:self.width,horizontalPadding: 20,verticalPadding: 20,alignment: .topLeading){inner_w in
            self.headerView(w: inner_w)
            if let text = self.tweet.text{
                MainText(content: text, fontSize: 15, color: .white.opacity(0.75), fontWeight: .medium)
            }
        }
    }
}
