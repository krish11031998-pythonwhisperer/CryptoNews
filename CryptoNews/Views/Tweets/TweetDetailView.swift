//
//  TweetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/03/2022.
//

import SwiftUI

struct TweetDetailView:View{
    @EnvironmentObject var context:ContextData
    @StateObject var tweet:CrybseTweet
    var width:CGFloat = .zero
    var isRetweet:Bool = false
    
    init(tweet:CrybseTweet,width:CGFloat,isRetweet:Bool = false){
        self.width = width
        self._tweet = .init(wrappedValue: tweet)
        self.isRetweet = isRetweet
    }
    
    
    var body:some View{
        Container(width:self.width,ignoreSides: true,verticalPadding: 0, lazyLoad: true){ inner_w in
            self.innerView(inner_w: inner_w)
                .basicCard()
                .borderCard(color: self.isRetweet ? .white : .gray.opacity(0.5), clipping: .roundClipping)
            if !self.isRetweet{
                self.TweetPoll(w: inner_w)
            }
            
        }.onAppear(perform: self.fetchRetweets)
        
    }
    
}

extension TweetDetailView{
    
    func fetchRetweets(){
        if let refTweet = self.tweet.referenceTweet,let id = refTweet.id{
            CrybseTwitterAPI.shared.getTweetData(endpoint: .tweetDetails, queryItems: ["tweet_id": id]) { data in
                if let safeData = data,let safeTweet = CrybseTweet.parseTweetFromData(data: safeData){
                    self.tweet.retweetedTweet = safeTweet
                }
            }
        }
    }
    
    @ViewBuilder func TweetPoll(w:CGFloat) -> some View{
        Container(width: w, ignoreSides: true,horizontalPadding: 0,verticalPadding: 0) { inner_w in
            CrybsePoll(poll: .init(question: "What is the sentiment of the tweet", options: ["Bearish","Bullish"]), width: inner_w)
            Container(heading: "Reactions", headingColor: .white, headingDivider: false, headingSize: 20, width: inner_w) { w in
                CustomWrappedTextHStack(data: ["Fake News","Trusted News","Overraction","Quality Analysis","Bad analysis"], width: inner_w, fontSize: 14, fontColor: .white, fontWeight: .medium, padding: 10, borderColor: .white, clipping: .roundCornerMedium, background: .clear, widthPadding: 15) { textVal in
                    print("Clicked on : ",textVal)
                }
                self.ReactionsBreakdownView(w: w)
            }.basicCard()
        }
        
    }
    
    var reactions:[String:Float]{
        ["Fake News":Float.random(in: 0...15),"Trusted News":Float.random(in: 0...15),"Overreaction":Float.random(in: 0...15),"Quality Reaction":Float.random(in: 0...15),"Bad analysis":Float.random(in: 0...15)]
    }
    
    var reactionColors:[String:Color]{
        ["Fake News":Color.red,"Trusted News":Color.green,"Overreaction":Color.orange,"Quality Reaction":Color.blue,"Bad analysis":Color.gray]
    }
    
    var reactionMaps:[Color:Float]?{
        var map = [Color:Float]()
        for (reaction,r_count) in reactions{
            if let color = reactionColors[reaction]{
                map[color] = r_count
            }
        }
        return map
    }
    
    @ViewBuilder func ReactionsBreakdownView(w:CGFloat) -> some View{
        if let safeReactionMap = self.reactionMaps{
            DonutChart(selectedColor: nil, diameter: w * 0.45, lineWidth: 15, valueColorPair: safeReactionMap)
                .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .right, spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(self.reactionColors.keys),id:\.self){ reaction in
                            if let safeColor = self.reactionColors[reaction],let safeCount = self.reactions[reaction]{
                                HStack(alignment: .center, spacing: 10) {
                                    Circle()
                                        .fill(safeColor)
                                        .frame(width: 10, height: 10, alignment: .center)
                                    MainText(content: reaction, fontSize: 10, color: .white, fontWeight: .medium)
                                    MainText(content: safeCount.ToDecimals(), fontSize: 10, color: .white, fontWeight: .medium)
                                }
                            }
                        }
                    }
                }
        }
        
    }
    
    
    @ViewBuilder func innerView(inner_w w:CGFloat) -> some View{
        Container(width: w,ignoreSides:false){ inner_w in
            self.Header(width: inner_w)
            self.Body(w: inner_w)
            self.attachmentsView(w: inner_w)
            self.urlAttachment(w: inner_w)
            self.EntitySection(w: inner_w)
            self.Footer(width: inner_w)
        }
    }
    
    @ViewBuilder func EntitySection(w:CGFloat) -> some View{
        if !self.tweet.Entities.isEmpty{
            Container(heading: "Entities", headingColor: .white, headingDivider: false, headingSize: 14, width: w,horizontalPadding: 5,verticalPadding: 5,spacing: 5) { inner_w in
                CustomWrappedTextHStack(data: self.tweet.Entities, width: inner_w,fontSize: 11)
            }
        }
    }
    
    @ViewBuilder func largeAttachmentWithImageView(width w:CGFloat,url:CrybseTweetURLEntity) -> some View{
        Container(width: w, ignoreSides: true,verticalPadding: 0,spacing: 0) { _ in
            ImageView(url: url.images?.first?.url,width: w,height: totalHeight * 0.25, contentMode: .fill, alignment: .center)
            Container(width: w) { _ in
                MainText(content: url.Title, fontSize: 15, color: .white, fontWeight: .medium)
                    .fixedSize(horizontal: false, vertical: true)
                MainText(content: url.Description, fontSize: 13, color: .gray, fontWeight: .medium)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
        }
        .basicCard()
        .borderCard(color: .white, clipping: .roundClipping)
        .buttonify {
            self.context.selectedLink = .init(string: url.Unwound_URL)
        }
    }
    
    @ViewBuilder func attachmentsView(w:CGFloat) ->  some View{
        if let safeMedia = self.tweet.media{
            if safeMedia.count == 1,let firstMedia = safeMedia.first{
                ImageView(url: firstMedia.url, width: w, contentMode: .fill, alignment: .center, autoHeight: true,clipping: .roundCornerMedium)
            }else if safeMedia.count > 1{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(Array(safeMedia.enumerated()),id:\.offset){ _media in
                            let media = _media.element
                            ImageView(url: media.url, width: width * 0.75, contentMode: .fill, alignment: .center, autoHeight: true,clipping: .roundCornerMedium)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder func urlAttachment(w:CGFloat) ->  some View{
        if let firstUrl = self.tweet.urls?.first{
            if let img = firstUrl.images?.first?.url, firstUrl.title != "" && firstUrl.description != ""{
                self.largeAttachmentWithImageView(width: w, url: firstUrl)
            }else if firstUrl.expanded_url != ""{
                MainText(content: firstUrl.Description != "" ? firstUrl.Description : firstUrl.DisplayURL, fontSize: 15, color: .blue, fontWeight: .medium)
                    .padding(.horizontal,10)
                    .buttonify {
                        self.context.selectedLink = .init(string: firstUrl.ExpandedURL)
                    }
            }else{
                Color.clear.frame(width: .zero, height: .zero, alignment: .center)
            }
            
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }
    
    
    @ViewBuilder func Body(w:CGFloat) -> some View{
//        if let referencedTweetId = self.tweet.referenceTweet?.id{
//            TweetDetailMainView(tweet_id: referencedTweetId,width: w, isRetweet: true, enableOnClose: false)
//        }
        if let retweetedTweet = self.tweet.retweetedTweet{
            TweetDetailView(tweet: retweetedTweet, width: w,isRetweet: true)
        }else if self.tweet.referenceTweet == nil{
            MainText(content: self.tweet.Text, fontSize: 14, color: .white,fontWeight: .regular,style: .heading,addBG: false ,padding: 10)
                .frame(width: w, alignment: .topLeading)
        }
    }
    
    @ViewBuilder func Header(width w:CGFloat) -> some View{
        if let user = self.tweet.user{
            HStack(alignment: .center, spacing: 15) {
                ImageView(url: user.profile_image_url, width: 45, height: 45, contentMode: .fill, alignment: .center)
                    .clipContent(clipping: .circleClipping)
                MainTextSubHeading(heading: "@\(user.username ?? "Tweet")", subHeading:
                                self.tweet.CreateAtDateString, headingSize: 12.5, subHeadingSize: 10, headColor: .white, subHeadColor: .gray, headingWeight: .semibold, bodyWeight: .regular,spacing: 0, alignment: .leading)
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
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var context:ContextData
    var tweet_id:String? = nil
    @State var tweet:CrybseTweet? = nil
    var enableOnClose:Bool
    var isRetweet:Bool
    var width:CGFloat
    
    init(tweet:CrybseTweet? = nil,tweet_id:String = "1507635970430189570",width:CGFloat = totalWidth,isRetweet:Bool = false,enableOnClose:Bool = true){
        if let safeTweet = tweet{
            self._tweet = .init(initialValue: safeTweet)
        }
        self.isRetweet = isRetweet
        self.tweet_id = tweet_id
        self.width = width
        self.enableOnClose = enableOnClose
    }
    
    func onAppear(){
        if self.tweet == nil,let safeTweetID = self.tweet_id{
            CrybseTwitterAPI.shared.getTweetData(endpoint: .tweetDetails, queryItems: ["tweet_id": safeTweetID]) { data in
                guard let safeData = data,let safeTweet = CrybseTweet.parseTweetFromData(data: safeData) else {return}
                setWithAnimation {
                    self.tweet = safeTweet
                }
            }
        }
    }
    
    func onClose(){
        self.presentationMode.wrappedValue.dismiss()
        if self.context.selectedTweet != nil{
            self.context.selectedTweet = nil
        }
    }
    
    @ViewBuilder var innerView:some View{
        Container(width: self.width,horizontalPadding: self.isRetweet ? 0 : 10,verticalPadding: 10,onClose: !self.isRetweet && self.enableOnClose ? self.onClose : nil,innerView: self.twitterViewBuilder(w:))
    }
    
    @ViewBuilder func twitterViewBuilder(w:CGFloat) -> some View{
        if let safeTweet = self.tweet{
            TweetDetailView(tweet: safeTweet, width: w,isRetweet: self.isRetweet)
        }else if CrybseTwitterAPI.shared.loading {
            ProgressView()
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }

    var body: some View{
        self.innerView
            .onAppear(perform: self.onAppear)
    }
}

struct TweetDetailHelperPreviews:PreviewProvider{
    static var previews: some View{
        if let firstTweet = CrybseSocialHighlightsAPI.loadStaticSocialHighlights()?.tweets?.first{
            ScrollView(showsIndicators: false) {
                TweetDetailMainView(tweet:firstTweet)
            }
            .background(Color.AppBGColor.ignoresSafeArea())
            
        }else{
            ProgressView()
        }
        
    }
}
