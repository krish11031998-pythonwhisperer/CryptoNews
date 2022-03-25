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
            self.mainBody
            self.hoverView
            if self.context.bottomSwipeNotification.showNotification{
                self.context.bottomSwipeNotification.generateView()
            }
            if self.context.showTab{
                TabBarMain()
                    .zIndex(2)
            }
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
        [.home,.search,.info,.profile,.currency,.txn,.post]
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
                    self.tabPage(page: tab)
                    .tag(tab)
                    .background(Color.AppBGColor)
                    .overlay(self.blurView)
                    .ignoresSafeArea()
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
            default: Color.clear
        }
    }
    
    var infoFeedView:some View{
        SlideTabView {
            return [AnyView(CrybPostMainView()),AnyView(CurrencyFeedMainPage(type: .feed)),AnyView(CurrencyFeedMainPage(type: .news))]
        }.environmentObject(self.context)
    }
        
    var hoverViewEnabled:Bool{
        return self.context.selectedLink != nil || self.context.addTxn || self.context.tab == .txn || self.context.selectedAsset != nil || self.context.selectedPost != nil || self.context.addTxn || self.context.addPost
    }
    
    @ViewBuilder var hoverView:some View{
        if let url = self.context.selectedLink{
            WebModelView(url: url, close: self.closeLink)
                .transition(.slideInOut)
                .zIndex(3)
        }
        
        if self.context.addTxn{
            AddTxnMainView(currency: self.context.selectedSymbol)
                .transition(.slideInOut)
                .zIndex(3)
        }
        
        if let asset = self.context.selectedAsset{
            CurrencyView(asset:asset, size: .init(width: totalWidth, height: totalHeight), onClose: self.closeAsset)
            .transition(.slideInOut)
            .background(Color.AppBGColor)
            .edgesIgnoringSafeArea(.all)
            .zIndex(self.context.showPortfolio ? 3 : 2)
        }
        
        if let post = self.context.selectedPost{
            CrybPostDetailView(postData: post)
                .environmentObject(self.context)
                .transition(.slideInOut)
                .background(Color.AppBGColor)
                .edgesIgnoringSafeArea(.all)
                .zIndex(2)
        }

        if self.context.addPost{
            CrybsePostMainView()
                .environmentObject(self.context)
                .transition(.slideInOut)
                .background(Color.AppBGColor)
                .edgesIgnoringSafeArea(.all)
                .zIndex(2)
        }
        
        if let safeAssetOverTime = self.context.assetOverTime,self.context.showPortfolio{
            PortfolioMain(assetOverTime:safeAssetOverTime)
                .environmentObject(self.context)
                .transition(.slideInOut)
                .background(Color.AppBGColor)
                .edgesIgnoringSafeArea(.all)
                .zIndex(2)
        }
    
    }
    
    func closeAsset(){
        setWithAnimation {
            if self.context.selectedAsset != nil{
                self.context.selectedAsset = nil
                
            }else if self.context.selectedSymbol != nil{
                self.context.selectedSymbol = nil
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CrybseView()
            .environmentObject(ContextData())
    }
}
