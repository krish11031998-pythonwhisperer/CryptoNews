//
//  RedditSnapshot.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/04/2022.
//

import SwiftUI

struct RedditSnapshot: View {
    
    var redditPost:CrybseRedditData
    var width:CGFloat
    var height:CGFloat
    
    init(redditPost:CrybseRedditData,width:CGFloat,height:CGFloat? = nil){
        self.redditPost = redditPost
        self.width = width
        self.height = height ?? .zero
    }
    
    func Header(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "u/\(self.redditPost.Author)", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
            MainText(content: "r/\(self.redditPost.SubReddit)", fontSize: 12, color: .white, fontWeight: .regular,padding: 5)
                .background(Color.orange.overlay(BlurView.thinDarkBlur).opacity(0.45).clipContent(clipping: .roundClipping))
                .borderCard(color: Color.orange, clipping: .roundClipping)
//                .blobify(color: AnyView(BlurView.thinLightBlur), clipping: .roundCornerMedium)
        }.frame(width: w, alignment: .center)
    }
    
    @ViewBuilder func mainView(w:CGFloat) -> some View{
        if let _ = self.redditPost.title{
            if self.height == .zero{
                MainText(content: self.redditPost.Title, fontSize: 15, color: .white, fontWeight: .medium)
            }else{
                MainText(content: self.redditPost.Title, fontSize: 15, color: .white, fontWeight: .medium)
                    .lineLimit(2)
            }
        }
        if let _ = self.redditPost.selftext{
            if self.height == .zero{
                MainText(content: self.redditPost.SelfText, fontSize: 13, color: .white, fontWeight: .regular)
            }else{
                MainText(content: self.redditPost.SelfText, fontSize: 13, color: .white, fontWeight: .regular)
                    .lineLimit(3)
            }
        }
    }
    
    var body: some View {
        Container(width:self.width,horizontalPadding: 0,verticalPadding: 3.5,alignment: .topLeading){ inner_w in
            self.Header(w: inner_w)
            self.mainView(w: inner_w)
        }
    }
}

