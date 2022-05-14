//
//  ContentView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct CrybseView: View {
    @EnvironmentObject var context:ContextData
    
    var contentView:some View{
        ZStack(alignment: .bottom) {
            Color.AppBGColor.zIndex(0)
//            self.mainBody
//            if self.context.bottomSwipeNotification.showNotification{
//                self.context.bottomSwipeNotification.generateView()
//            }
//            if self.context.showTab{
//                TabBarMain()
//                    .zIndex(2)
//            }
//            CurrencyFeedMainPage(type: .reddit)
            self.infoFeedView
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    var body: some View {
        self.contentView
    }
}

extension CrybseView{
    
    var tabs:[Tabs]{
        [.home,.search,.portfolio,.info,.profile]
    }
    
    func closeLink(){
        if self.context.selectedLink != nil{
            self.context.selectedLink = nil
        }
    }
    
    var blurView:some View{
        self.context.addButtonPressed ?
            BlurView(style: .light)
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
                .edgesIgnoringSafeArea(.all)
                    .anyViewWrapper() : Color.clear.anyViewWrapper()
    }
    
    @ViewBuilder var mainBody:some View{
        TabView(selection: $context.tab){
            ForEach(self.tabs, id: \.rawValue) { tab in
//                CustomNavigationView {
                    self.tabPage(page: tab)
                    .tag(tab)
//                }
            }
        }
        .onAppear {
            UITabBar.appearance().isHidden = true
            UITabBar.appearance().barTintColor = .clear
        }
    }
    
    @ViewBuilder func tabPage(page:Tabs) -> some View{
        switch(page){
            case .home: HomePage().environmentObject(self.context)
            case .search: SearchMainPage().environmentObject(self.context)
            case .info: self.infoFeedView
            case .profile: ProfileView().environmentObject(self.context)
            case .portfolio : self.portfolioView
            default: Color.clear
        }
    }
    
    @ViewBuilder var portfolioView:some View{
        if self.context.userAssets.trackedAssets.isEmpty{
            MainText(content: "You have no portfolio Assets", fontSize: 15)
        }else{
            PortfolioMain(assetOverTime: self.context.assetOverTime, assets: self.context.userAssets.trackedAssets)
        }
    }
    
    var infoFeedView:some View{
        SlideTabView {
            [FeedPageType.twitter,FeedPageType.reddit,FeedPageType.news].compactMap({CurrencyFeedMainPage(type: $0).anyViewWrapper()})
        }.environmentObject(self.context)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CrybseView()
            .environmentObject(ContextData())
    }
}
