//
//  ContentView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var context:ContextData
    
    func closeNews(){
        if self.context.selectedNews != nil{
//            withAnimation(.easeInOut(duration: 0.5)) {
                self.context.selectedNews = nil
//            }
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
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
    
    var body: some View {
        self.contentView
    }
}

extension ContentView{
    
    @ViewBuilder var mainBody:some View{
        switch(self.context.tab){
            case .home: self.homeView
            case .info :
                SlideTabView {
                    return [AnyView(CurrencyFeedMainPage(type: .feed).environmentObject(self.context)),AnyView(CurrencyFeedMainPage(type: .news).environmentObject(self.context))]
                }
            case .txn:
                AddTxnMainView()
                    .environmentObject(self.context)
            case .search:
                    SearchMainPage()
            case .profile:
                    ProfileView()
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
    
    
    @ViewBuilder var hoverView:some View{
        if let news = self.context.selectedNews, let urlStr = news.url,let url  = URL(string: urlStr){
            WebModelView(url: url, close: self.closeNews)
                .transition(.slideInOut)
                .zIndex(3)
        }
        if self.context.addTxn{
            AddTxnMainView(currency: self.context.selectedSymbol)
                .transition(.slideInOut)
                .zIndex(3)
        }
        
        if let asset = self.context.selectedCurrency{
            self.CurrencyViewGetter(asset: asset, height: totalHeight * 0.3)
        }else if let symb = self.context.selectedSymbol{
            self.CurrencyViewGetter(name: symb, height: totalHeight * 0.3)
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
    
    
    func CurrencyViewGetter(asset:AssetData,height h :CGFloat) -> some View{
        CurrencyView(info: asset, size: .init(width: totalWidth, height: totalHeight), onClose: self.closeAsset)
        .transition(.slideInOut)
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
        .zIndex(2)
    }
    
    func CurrencyViewGetter(name:String,height h :CGFloat) -> some View{
        CurrencyView(name: name, size: .init(width: totalWidth, height: totalHeight), onClose: self.closeAsset)
        .transition(.slideInOut)
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
        .zIndex(2)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContextData())
    }
}
