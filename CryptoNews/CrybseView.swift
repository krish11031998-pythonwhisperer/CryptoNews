//
//  ContentView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct CrybseView: View {
    @EnvironmentObject var context:ContextData
    
    func closeNews(){
        if self.context.selectedNews != nil{
            self.context.selectedNews = nil
        }
    }
    
    var contentView:some View{
        ZStack(alignment: .bottom) {
            mainBGView.zIndex(0)
            self.mainBody
            self.hoverView
            if self.context.showTab{
                TabBarMain()
                    .zIndex(2)
            }
            if self.context.bottomSwipeNotification.showNotification{
                self.notificationView
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
    
    var body: some View {
        self.contentView
            .onPreferenceChange(AddTxnUpdatePreference.self) { added_Txn in
                if let uid = self.context.user.user?.uid, added_Txn{
                    self.context.transactionAPI.loadTransaction(uuid: uid)
                }
            }
            .onAppear {
                self.context.addPost.toggle()
            }
    }
}

extension CrybseView{
    
    var tabs:[Tabs]{
        return [.home,.search,.info,.profile]
    }
    
    @ViewBuilder var mainBody:some View{
        ZStack(alignment: .center) {
            ForEach(self.tabs, id: \.rawValue) { tab in
                if self.context.tab == tab{
                    self.tabPage(page: tab).tag(tab)
                }else{
                    Color.clear
                }
                
            }
        }
    }
    
    @ViewBuilder func tabPage(page:Tabs) -> some View{
        switch(page){
            case .home: self.homeView
            case .search: SearchMainPage()
            case .info: SlideTabView {
                return [AnyView(CrybPostMainView().environmentObject(self.context)),AnyView(CurrencyFeedMainPage(type: .feed).environmentObject(self.context)),AnyView(CurrencyFeedMainPage(type: .news).environmentObject(self.context))]
            }
            case .profile: ProfileView()
            default: Color.clear
        }
    }
    
    
    @ViewBuilder var homeView:some View{
        HomePage()
            .environmentObject(self.context)
    }
    
    var hoverViewIsOn:Bool{
        return self.context.addTxn || self.context.selectedCurrency != nil || self.context.selectedNews != nil || self.context.selectedSymbol != nil
    }
    
    var hoverViewEnabled:Bool{
        return self.context.selectedNews != nil || (self.context.addTxn || self.context.tab == .txn) || self.context.selectedCurrency != nil || self.context.selectedPost != nil
    }
    
    @ViewBuilder var hoverView:some View{
        if let news = self.context.selectedNews, let urlStr = news.url,let url  = URL(string: urlStr){
            WebModelView(url: url, close: self.closeNews)
                .transition(.slideInOut)
                .zIndex(3)
        }
        
        if self.context.addTxn || self.context.tab == .txn{
            AddTxnMainView(currency: self.context.selectedSymbol)
                .transition(.slideInOut)
                .zIndex(3)
        }
        
        if self.context.selectedCurrency != nil || self.context.selectedSymbol != nil{
            CurrencyView(name: self.context.selectedSymbol, info: self.context.selectedCurrency, size: .init(width: totalWidth, height: totalHeight), onClose: self.closeAsset)
            .transition(.slideInOut)
            .background(mainBGView)
            .edgesIgnoringSafeArea(.all)
            .zIndex(2)
        }
        
        if let post = self.context.selectedPost{
            CrybPostDetailView(postData: post)
                .transition(.slideInOut)
                .background(mainBGView)
                .edgesIgnoringSafeArea(.all)
                .zIndex(2)
        }
        

        if self.context.addPost{
            CrybPostGen()
                .transition(.slideInOut)
                .background(mainBGView)
                .edgesIgnoringSafeArea(.all)
                .zIndex(2)
        }

        
    
    }
    
    @ViewBuilder var notificationView:some View{
        BottomSwipeCard(width: totalWidth, heading: self.context.bottomSwipeNotification.heading, buttonText: self.context.bottomSwipeNotification.buttonText) {
            MainText(content: self.context.bottomSwipeNotification.innerText, fontSize: 15,fontWeight: .medium)
        } action: {
            if let action = self.context.bottomSwipeNotification.action{
                action()
            }else{
                print("Nothing to do here!")
                DispatchQueue.main.async {
                    self.context.bottomSwipeNotification.showNotification = false
                }
            }
        }
    }
    
    func closeAsset(){
        if self.context.selectedCurrency != nil{
            withAnimation(.easeInOut(duration: 0.5)) {
                self.context.selectedCurrency = nil
            }
        }else if self.context.selectedSymbol != nil{
            withAnimation(.easeInOut(duration: 0.5)) {
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
