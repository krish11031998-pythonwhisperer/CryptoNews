//
//  ReddtiDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/04/2022.
//

import SwiftUI

struct RedditDetailView: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var context:ContextData
    var reddit:CrybseRedditData
    var width:CGFloat

    
    init(reddit:CrybseRedditData,width:CGFloat = totalWidth){
        self.width = width
        self.reddit = reddit
    }
    
    @ViewBuilder func imageView(w:CGFloat) -> some View{
        if self.reddit.URLStr.isImgURLStr(){
            ImageView(url: self.reddit.URLStr, width: w, contentMode: .fill, alignment: .center, autoHeight: true,clipping: .roundClipping)
        }
    }
    
    @ViewBuilder func redditPostMessage(w:CGFloat) -> some View{
        if !self.reddit.SelfText.isEmpty{
            MainText(content: self.reddit.SelfText, fontSize: 15, color: .white, fontWeight: .medium)
                .frame(width: w, alignment: .topLeading)
        }
    }
    
    @ViewBuilder func headerView(w:CGFloat) -> some View{
        if !self.reddit.Title.isEmpty{
            Container(width: w, ignoreSides: true,verticalPadding: 0) { inner_w in
                HStack(alignment: .center, spacing: 10) {
                    MainText(content: self.reddit.Author, fontSize: 17.5, color: .white, fontWeight: .medium)
                    Spacer()
                    MainText(content: self.reddit.Subreddit_name_prefixed, fontSize: 12.5, color: .white, fontWeight: .medium)
                        .blobify(clipping:.roundClipping)
                }
                MainText(content: self.reddit.Title, fontSize: 17.5, color: .white, fontWeight: .semibold)
            }
        }
    }
    
    func onClose(){
        self.presentationMode.wrappedValue.dismiss()
        if self.context.selectedReddit != nil{
            self.context.selectedReddit = nil
        }
    }
    
    
    @ViewBuilder func mainInnerBodyView(w inner_w:CGFloat) -> some View{
        self.headerView(w: inner_w)
        self.redditPostMessage(w: inner_w)
        self.imageView(w: inner_w)
    }
    
    var body: some View {
        Container(width: self.width,onClose: self.onClose,innerView: self.mainInnerBodyView(w:))
            .basicCard()
    }
}

struct RedditDetailMainView:View {
    
    @EnvironmentObject var context:ContextData
    var redditData:CrybseRedditData
    var enableOnClose:Bool
    
    init(redditData:CrybseRedditData,enableClose:Bool = true){
        self.redditData = redditData
        self.enableOnClose = enableClose
    }
    
    func onClose(){
        print("(DEBUG) onClose On RedditDetailMainView")
        if self.context.selectedReddit != nil{
            self.context.selectedReddit = nil
        }
    }
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            if self.enableOnClose{
                Container(width: totalWidth,horizontalPadding: 10,verticalPadding: 50,onClose: self.onClose) { w in
                    RedditDetailView(reddit: self.redditData, width: w)
                }
            }else{
                Container(width: totalWidth,horizontalPadding: 10,verticalPadding: 50) { w in
                    RedditDetailView(reddit: self.redditData, width: w)
                }
            }
            
        }
        
    }
}


struct RedditDetailViewTester:View{
    
    @State var redditData:CrybseRedditData? = nil
    
    func onAppear(){
        if self.redditData == nil{
            CrybseRedditAPI.shared.getRedditPosts(search: "AVAX", limit: 10) { data in
                if let safeData = data,let safeRedditData = CrybseRedditPosts.parseFromData(data: safeData)?.last{
                    setWithAnimation {
                        self.redditData = safeRedditData
                    }
                }
                
                if CrybseRedditAPI.shared.loading{
                    setWithAnimation {
                        CrybseRedditAPI.shared.loading.toggle()
                    }
                }
            }
        }
    }
    
    var body: some View{
        ZStack(alignment: .center) {
            if let safeRedditData = self.redditData{
                RedditDetailMainView(redditData: safeRedditData)
            }else if CrybseRedditAPI.shared.loading{
                ProgressView()
            }else{
                MainText(content: "No RedditData Provided", fontSize: 15, color: .white, fontWeight: .medium)
            }
        }
        .onAppear(perform: self.onAppear)
    }
}

struct ReddtiDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RedditDetailViewTester()
            .background(Color.AppBGColor.ignoresSafeArea())
    }
}
