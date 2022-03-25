//
//  SocialFeedSummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/03/2022.
//

import SwiftUI

struct SocialFeedSummaryView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var assetFeedManager:CrybseAssetSocialsAPI
    var width:CGFloat
    
    init(assets:[String],width:CGFloat){
        var queryItems:[String:Any] = [:]
        for asset in assets {
            queryItems["asset"] = asset
        }
        self._assetFeedManager = .init(wrappedValue: .init(type: .socialHighlights, queryItems: queryItems))
        self.width = width
    }
    
    func onAppear(){
        self.assetFeedManager.getAssetSocialData()
    }
    
    func cardSize(w:CGFloat? = nil) -> CGSize{
        return .init(width: w ?? self.width, height: totalHeight * 0.3)
    }
    
    @ViewBuilder func cardBuilder(_ data:Any,_ size:CGSize) -> some View{
        if let safeData = data as? CrybseSocialData{
            if safeData.isTweet{
                PostCard(cardType: .Tweet, data: safeData, size: size, bg: .light, const_size: true,isButton: false)
            }else{
                NewsCard(news: safeData, size: size)
            }
        }
    }
    
    @ViewBuilder var SocialSummayView:some View{
        if let socialFeed = self.assetFeedManager.data as? Array<CrybseSocialData>{
            Container(heading: "Social Feed Summary", width: self.width) { inner_w in
                SlideZoomInOutView(data: socialFeed,timeLimit: 10,size: self.cardSize(w: inner_w), scrollable: true,viewGen:self.cardBuilder(_:_:))
            }
        }else if self.assetFeedManager.loading{
            ProgressView()
                .frame(width:self.cardSize().width,height:self.cardSize().height,alignment:.center)
                .clipContent(clipping: .roundClipping)
        }else{
            Color.clear
        }

    }
    
    var body: some View {
        self.SocialSummayView
            .onAppear(perform: self.onAppear)
    }
}

struct SocialFeedSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            SocialFeedSummaryView(assets: ["AVAX","DOT","LTC"], width: totalWidth - 30)
            Spacer()
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.AppBGColor)
        .ignoresSafeArea()
    }
}
