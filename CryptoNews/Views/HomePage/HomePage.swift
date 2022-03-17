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
    
    
    var mainView:some View{
        ScrollView(.vertical,showsIndicators:false){
            
            Spacer().frame(height: 50)
            AllAssetView().asyncContainer()
            LatestRedditPost(currencies: self.currencies).asyncContainer()
            NewsSectionMain(currencies: self.currencies, limit: 10, cardHeight: totalHeight * 0.35)
            self.pollView
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
