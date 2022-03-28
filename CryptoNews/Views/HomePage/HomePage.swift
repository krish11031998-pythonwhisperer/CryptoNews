//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var context:ContextData
    
    var activeCurrency:Bool{
        return self.context.selectedAsset != nil
    }
    
    var currencies:[String]{
        return self.context.user.user?.watching ?? ["BTC","LTC","ETH","XRP"]
    }
    
    var watchedAsset:[String]{
        return self.context.userAssets.trackedAssets.compactMap({$0.Currency})
    }
    
    
    var mainView:some View{
        ScrollView(.vertical,showsIndicators:false){
            Spacer().frame(height: 50)
            AllAssetView().asyncContainer()
                .animatedAppearance()
            self.SocialFeedSummary
                .animatedAppearance()
            LatestRedditPost(width:totalWidth,height:totalHeight * 0.3,currencies: self.currencies).asyncContainer()
                .animatedAppearance()
            NewsSectionMain(currencies: self.currencies, limit: 10, cardHeight: totalHeight * 0.35)
                .animatedAppearance()
            self.pollView
            QuickWatch(assets: self.context.userAssets.trackedAssets + self.context.userAssets.watchingAssets)
                .animatedAppearance()
            Spacer(minLength: 200)
        }.zIndex(1)
    }
    
    var body: some View {
        ZStack(alignment: .center){
            self.mainView
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}


extension HomePage{
    
    var pollData:Array<CrybsePollData>{
        Array(1...5).compactMap({CrybsePollData(question: "Question \($0)")})
    }
    
    @ViewBuilder var SocialFeedSummary:some View{
        if !self.watchedAsset.isEmpty{
            SocialFeedSummaryView(assets: self.watchedAsset, width: totalWidth)
        }else{
            SocialFeedSummaryView(width: totalWidth)
        }
    }
    
    @ViewBuilder var pollView:some View{
        Container(heading: "Poll",width: totalWidth,spacing: 40) { w in
            CardFanView(width: w, indices: self.pollData, isScrollable: false) { poll in
                if let safePoll = poll as? CrybsePollData{
                    CrybsePoll(poll: safePoll, width: w, height: 250,alertEventChange: true)
                }
            }
        }.asyncContainer()
    }
    
}

struct HomePage_Previews: PreviewProvider {
    @StateObject static var context:ContextData = .init()
    static var previews: some View {
        HomePage()
            .environmentObject(HomePage_Previews.context)
            .background(Color.mainBGColor.ignoresSafeArea())
    }
}
