//
//  RedditPostCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import SwiftUI

enum RedditPostCardSize:CGFloat{
    case small = 200
}

struct RedditPostCard: View {
    @EnvironmentObject var context:ContextData
    var redditPost:CrybseRedditData
    var width:CGFloat
    var size:CGSize = .zero
    var const_size:Bool = false
    var isButton:Bool
    
    init(width:CGFloat,size:CGSize = .zero,redditPost:CrybseRedditData,const_size:Bool = false,isButton:Bool = true){
        self.redditPost = redditPost
        self.width = width
        self.size = size
        self.isButton = isButton
        self.const_size = const_size
    }
    
    func Header(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: "u/\(self.redditPost.Author)", fontSize: 13, color: .white, fontWeight: .semibold)
            Spacer()
            MainText(content: "r/\(self.redditPost.SubReddit)", fontSize: 10, color: .white, fontWeight: .regular)
                .blobify(color: AnyView(BlurView.thinLightBlur), clipping: .roundCornerMedium)
        }.frame(width: w, alignment: .center)
    }
    
    @ViewBuilder func MainBody(size:CGSize) -> some View{
        if self.size.height != .zero{
            self.mainBody(w: size.width)
                .truncationMode(.tail)
        }else{
            self.mainBody(w: size.width)
        }
    }
    
    @ViewBuilder func mainBody(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 15) {
            if let _ = self.redditPost.title{
                MainText(content: self.redditPost.Title, fontSize: 15, color: .white, fontWeight: .medium)
            }
            if let _ = self.redditPost.selftext{
                MainText(content: self.redditPost.SelfText, fontSize: 13, color: .white, fontWeight: .regular)
            }
            if self.redditPost.URLStr.isImgURLStr() && !self.const_size{
                ImageView(url: self.redditPost.URLStr, width: w, contentMode: .fill, alignment: .center, autoHeight: true)
                    .clipContent(clipping: .roundCornerMedium)
            }
        }.frame(width: w, alignment: .leading)
        .padding(.vertical,7.5)
        
    }
    
    func Footer(w:CGFloat) -> some View{
        
        return HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "suit.heart", b_content: "\(self.redditPost.Likes)", color: .white, haveBG:false,bgcolor: .white) {
                print("Pressed Like")
            }
            SystemButton(b_name: "arrow.2.squarepath", b_content: "\(self.redditPost.UpVote_Ratio)", color: .white, haveBG:false, bgcolor: .white) {
                print("Pressed Share")
            }
            Spacer()
        }.frame(width: w, alignment: .leading)
    }
    
    var mainBody:some View{
        Container(width: self.width,verticalPadding: 15,spacing: 10) { w in
            self.Header(w: w)
            self.MainBody(size: .init(width: w, height: size.height))
            if self.const_size{
                Spacer(minLength: 0)
            }
            Divider().background(Color.white).frame(width: w,height:5, alignment: .center)
            self.Footer(w: w)
        }
        .basicCard(size:self.const_size ?  self.size : .zero)
    }
    
    var body: some View {
        if self.isButton{
            self.mainBody
                .buttonify {
                    if self.context.selectedReddit != self.redditPost{
                        self.context.selectedReddit = self.redditPost
                    }
                }
        }else{
            self.mainBody
        }
    }
}

struct RedditCardTester:View{
    @StateObject var RAPI:CrybseRedditAPI
    var size:CGSize
    
    init(search:String,size:CGSize = .zero){
        self._RAPI = .init(wrappedValue: .init(search: search))
        self.size = size
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
                        RedditPostCard(width: w,size: size, redditPost: post.element,const_size: true)
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
        RedditCardTester(search: "bitcoin",size: .init(width: totalWidth - 30, height: RedditPostCardSize.small.rawValue) )
            .background(Color.mainBGColor.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
    }
}
