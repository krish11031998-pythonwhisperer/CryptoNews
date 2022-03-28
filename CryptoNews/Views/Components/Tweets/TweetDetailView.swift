//
//  TweetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/03/2022.
//

import SwiftUI

struct TweetDetailView:View{
    
    @EnvironmentObject var context:ContextData
    var tweet:CrybseTweet
    var width:CGFloat = .zero
    
    init(tweet:CrybseTweet,width:CGFloat){
        self.width = width
        self.tweet = tweet
        print("(DEBUG) tweet id : ",tweet.id ?? "tweet_id")
    }
    
    
    var body:some View{
        Container(width: self.width) { inner_w in
            self.innerView(inner_w: inner_w)
        }
        .basicCard()
    }
    
}

extension TweetDetailView{
    
    @ViewBuilder func innerView(inner_w:CGFloat) -> some View{
        self.Header(width: inner_w)
        self.Body(w: inner_w)
        self.urlAttachment(w: inner_w)
        self.EntitySection(w: inner_w)
        self.Footer(width: inner_w)
    }
    
    @ViewBuilder func EntitySection(w:CGFloat) -> some View{
        if !self.tweet.Entities.isEmpty{
            Container(heading: "Entities", headingColor: .white, headingDivider: false, headingSize: 14, width: w,horizontalPadding: 5,verticalPadding: 5,spacing: 5) { inner_w in
                CustomWrappedTextHStack(data: self.tweet.Entities, width: inner_w,fontSize: 11)
            }
        }
    }
    
    @ViewBuilder func urlAttachment(w:CGFloat) ->  some View{
        if let firstUrl = self.tweet.entity?.urls?.first{
            Container(width: w, ignoreSides: true,verticalPadding: 0,spacing: 0) { _ in
                ImageView(url: firstUrl.images?.first?.url,width: w,height: totalHeight * 0.25, contentMode: .fill, alignment: .center)
                Container(width: w) { _ in
                    MainText(content: firstUrl.title, fontSize: 15, color: .white, fontWeight: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                    MainText(content: firstUrl.description, fontSize: 13, color: .gray, fontWeight: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
            }
            .basicCard()
            .borderCard(color: .white, clipping: .roundClipping)
            .buttonify {
                self.context.selectedLink = .init(string: firstUrl.unwound_url)
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }
    
    
    @ViewBuilder func Body(w:CGFloat) -> some View{
        MainText(content: self.tweet.Text, fontSize: 14, color: .white,fontWeight: .regular,style: .heading,addBG: false ,padding: 10)

            .frame(width: w, alignment: .topLeading)
        
    }
    
    @ViewBuilder func Header(width w:CGFloat) -> some View{
        if let user = self.tweet.user{
            HStack(alignment: .center, spacing: 15) {
                ImageView(url: user.profile_image_url, width: 45, height: 45, contentMode: .fill, alignment: .center)
                    .clipContent(clipping: .circleClipping)
//                MainText(content: , fontSize: 12.5, color: .white, fontWeight: .medium)
                MainSubHeading(heading: "@\(user.username ?? "Tweet")", subHeading:
                                self.tweet.id ?? "Id", headingSize: 12.5, subHeadingSize: 10, headColor: .white, subHeadColor: .gray, headingWeight: .semibold, bodyWeight: .regular,spacing: 0, alignment: .leading)
                Spacer()
                ImageView(img: .init(named: "TwitterIcon"), width: 25, height: 25, contentMode: .fill, alignment: .center,clipping: .circleClipping)
            }
            .frame(width: w, alignment: .topLeading)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }

    @ViewBuilder func Footer(width w:CGFloat) -> some View{
        VStack(alignment: .center, spacing: 5){
            Divider().frame(width: w,height:5, alignment: .center)
            HStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "suit.heart", b_content: "\(tweet.Like)", color: .white, haveBG:false,bgcolor: .clear) {
                    print("Pressed Like")
                }
                SystemButton(b_name: "arrow.2.squarepath", b_content: "\(tweet.Retweet)", color: .white, haveBG:false, bgcolor: .clear) {
                    print("Pressed Share")
                }
                Spacer()
                self.SentimentView
            }
        }
        .frame(width: w, alignment: .leading)
    }
    
    @ViewBuilder var SentimentView:some View{
        let color = self.tweet.Sentiment > 3 ? Color.green : self.tweet.Sentiment < 3 ? Color.red : Color.gray
        let emoji = self.tweet.Sentiment > 3 ? "😁" : self.tweet.Sentiment < 3 ? "😓" : "😐"
        HStack(alignment: .center, spacing: 2.5) {
            MainText(content: "\(emoji) ", fontSize: 12,color: .white)
            MainText(content: String(format: "%.1f", self.tweet.Sentiment), fontSize: 12, color: .white,fontWeight: .semibold)
        }
        .padding(7.5)
        .padding(.horizontal,2.5)
        .basicCard(background: Color.gray.anyViewWrapper())
    }
}

struct TweetDetailMainView:View{
    
    @EnvironmentObject var context:ContextData
    var tweet_id:String? = nil
    @State var tweet:CrybseTweet? = nil
    
    init(tweet:CrybseTweet? = nil,tweet_id:String = "1507635970430189570"){
        self._tweet = .init(initialValue: tweet)
        self.tweet_id = tweet_id
    }
    
    func onAppear(){
        if self.tweet == nil,let safeTweetId = self.tweet_id{
            CrybseTwitterAPI.shared.getTweets(endpoint: .tweetDetails, queryItems: ["tweet_id": safeTweetId]) { data in
                guard let safeData = data,let safeTweet = CrybseTweet.parseTweetFromData(data: safeData) else {return}
                setWithAnimation {
                    self.tweet = safeTweet
                }
                if CrybseTwitterAPI.shared.loading{
                    CrybseTwitterAPI.shared.loading.toggle()
                }
                
            }
        }else{
            print(self.tweet)
        }
    }
    
    func onClose(){
        if self.context.selectedTweet != nil{
            self.context.selectedTweet = nil
        }
    }
    
    var body: some View{
        
        ZStack(alignment: .center) {
            Color.AppBGColor
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
            ScrollView(.vertical, showsIndicators: false) {
                Container(width: totalWidth,horizontalPadding: 10,verticalPadding: 50,onClose: self.onClose) { w in
                    if let safeTweet = self.tweet{
                        TweetDetailView(tweet: safeTweet, width: w)
                    }else if CrybseTwitterAPI.shared.loading {
                        ProgressView()
                    }else{
                        Color.clear.frame(width: .zero, height: .zero, alignment: .center)
                    }
                }
            }
        }.onAppear(perform: self.onAppear)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            .ignoresSafeArea()
        
    }
}

struct TweetDetailHelperPreviews:PreviewProvider{
    static var previews: some View{
        TweetDetailMainView(tweet_id: "1507637541691957250")
    }
}
