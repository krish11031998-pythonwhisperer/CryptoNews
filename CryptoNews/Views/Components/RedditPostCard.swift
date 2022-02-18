//
//  RedditPostCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import SwiftUI

struct RedditPostCard: View {
    var redditPost:CrybseRedditData
    var width:CGFloat
    var size:CGSize = .zero
    
    init(width:CGFloat,size:CGSize = .zero,redditPost:CrybseRedditData){
        self.redditPost = redditPost
        self.width = width
        self.size = size
    }
    
    func Header(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "u/\(self.redditPost.Author)", fontSize: 13, color: .white, fontWeight: .semibold)
            Spacer()
            MainText(content: "r/\(self.redditPost.SubReddit)", fontSize: 10, color: .white, fontWeight: .regular)
                .blobify(color: AnyView(BlurView.thinLightBlur), clipping: .roundCornerMedium)
        }.frame(width: w, alignment: .center)
    }
    
    @ViewBuilder func mainBody(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 15) {
            if let _ = self.redditPost.title{
                MainText(content: self.redditPost.Title, fontSize: 15, color: .white, fontWeight: .medium)
            }
            if let _ = self.redditPost.selftext{
                MainText(content: self.redditPost.SelfText, fontSize: 13, color: .white, fontWeight: .regular)
            }
            if self.redditPost.URL.isImgURLStr(){
                ImageView(url: self.redditPost.URL, width: w, contentMode: .fill, alignment: .center, autoHeight: true)
                    .clipContent(clipping: .roundCornerMedium)
            }
        }.frame(width: w, alignment: .leading)
            .padding(.vertical,7.5)
        
    }
    
    func footer(w:CGFloat) -> some View{
        
        return HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "suit.heart", b_content: "\(self.redditPost.Likes)", color: .black, haveBG:false,bgcolor: .white) {
                print("Pressed Like")
            }
            SystemButton(b_name: "arrow.2.squarepath", b_content: "\(self.redditPost.UpVote_Ratio)", color: .black, haveBG:false, bgcolor: .white) {
                print("Pressed Share")
            }
            Spacer()
        }.frame(width: w, alignment: .leading)
    }
    
    var body: some View {
        Container(width: self.width,verticalPadding: 15) { w in
            self.Header(w: w)
                .padding(.bottom,10)
            self.mainBody(w: w)
//            RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(width: w, height:0.5, alignment: .center)
            Divider().background(Color.white).frame(width: w,height:5, alignment: .center)
            self.footer(w: w)
        }.basicCard(size: self.size)
    }
}

struct RedditCardTester:View{
    @StateObject var RAPI:CrybseRedditAPI
    
    init(subReddit:String){
        self._RAPI = .init(wrappedValue: .init(subReddit: subReddit))
    }
    
    func onAppear(){
        if self.RAPI.posts.isEmpty{
            self.RAPI.getRedditPosts()
        }
    }
    
    @ViewBuilder var mainBody:some View{
        if !self.RAPI.posts.isEmpty{
            ScrollView(.vertical, showsIndicators: false) {
                Container(heading: "Reddit Posts", width: totalWidth) { w in
                    ForEach(Array(self.RAPI.posts.enumerated()), id:\.offset) { post in
                        RedditPostCard(width: w, redditPost: post.element)
                    }
                }
            }
        }else if self.RAPI.loading{
            ProgressView()
        }else{
            MainText(content: "No Reddit Posts", fontSize:15)
        }
    }
    
    var body: some View{
        self.mainBody
            .onAppear(perform: self.onAppear)
    }
}

struct RedditPostCard_Previews: PreviewProvider {
    static var previews: some View {
        RedditCardTester(subReddit: "bitcoin")
            .background(Color.mainBGColor.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
    }
}
