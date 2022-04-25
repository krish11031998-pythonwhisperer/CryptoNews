//
//  SocialFeedSummaryExpandedView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/04/2022.
//

import SwiftUI

struct SocialFeedSummaryExpandedView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var context:ContextData
    @State var idx:Int = .zero
    @Namespace var animation
    var data:[Any]
    
    init(data:[Any]){
        self.data = data
    }
    
    var pageSize:CGSize{
        .init(width: totalWidth, height: totalHeight - 100)
    }
    
    @ViewBuilder func pageBuilder(data:Any,size:CGSize) -> some View{
        ScrollView(.vertical, showsIndicators: false) {
            Container(width:size.width,ignoreSides:false) { w in
                if let tweet = data as? CrybseTweet{
                    TweetDetailView(tweet: tweet, width: w)
                }else if let reddit = data as? CrybseRedditData{
                    RedditDetailView(reddit: reddit, width: w)
                }
                Spacer().frame(height: totalHeight * 0.2)
            }.padding(.top,safeAreaInsets.top + totalHeight * 0.125)
        }
    }
    
    @ViewBuilder func scrollIndicator(size:CGSize) -> some View{
        let barWidth = size.width/CGFloat(self.data.count) - 2.5
        HStack(alignment: .center, spacing: 2.5) {
            ForEach(0..<self.data.count,id:\.self) { idx in
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                        .fill(Color.white.opacity(0.5))
                        .frame(width: barWidth, height: size.height, alignment: .center)
                    if self.idx == idx{
                        RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "selected", in: self.animation)
                            .frame(width: barWidth, height: size.height, alignment: .center)
                    }else{
                        Color.clear.frame(width: barWidth, height: size.height, alignment: .center)
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height, alignment: .leading)
    }
    
    func onClose(){
        if self.context.socialHighlightsData != nil{
            self.context.socialHighlightsData = nil
        }
    }
    var body: some View {
        ZStack(alignment: .top) {
            ZoomInScrollView(data: self.data, axis: .horizontal, centralizeStart: true,lazyLoad: true, size: .init(width: totalWidth, height: .zero), selectedCardSize: .init(width: totalWidth, height: .zero)) { data, size, _ in
                self.pageBuilder(data: data, size: size)
            }
            .onPreferenceChange(SelectedCentralCardPreferenceKey.self) { newValue in
                print("(DEBUG) newSelectorIndex : ",newValue)
                self.idx = newValue
            }
            Container(heading:"Social Highlights",headingDivider: false,width: totalWidth, onClose: self.onClose) { w in
                self.scrollIndicator(size: .init(width: w, height: 2.5))
            }
            .frame(width: totalWidth, height: totalHeight * 0.125, alignment: .center)
            .padding(.top,safeAreaInsets.top)
            .background(BlurView.thinLightBlur)
        }
        .onAppear {
            print("(DEBUG) safeAreaInsets : ",self.safeAreaInsets)
        }
    }
}


struct SocialFeedSummaryExpandedViewTester:View{
    @StateObject var socialHighlightAPI:CrybseSocialHighlightsAPI
    
    init(){
        self._socialHighlightAPI = .init(wrappedValue: .init(assets: ["AVAX","BTC"]))
    }
    
    var body: some View{
        ZStack(alignment: .topLeading) {
            if let socialHighlight = self.socialHighlightAPI.socialHightlight{
                SocialFeedSummaryExpandedView(data: (socialHighlight.Reddit + socialHighlight.Tweets).shuffled())
            }else if self.socialHighlightAPI.loading{
                ProgressView()
            }else{
                MainText(content: "No Data", fontSize: 15, color: .white, fontWeight: .medium)
            }
        }
        .onAppear {
            if self.socialHighlightAPI.socialHightlight == nil{
                self.socialHighlightAPI.getSocialHighlights()
            }
        }
        
    }
}

struct SocialFeedSummaryExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        SocialFeedSummaryExpandedViewTester()
    }
}
