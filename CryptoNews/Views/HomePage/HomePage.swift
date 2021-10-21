//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    var currencies:[String] = ["BTC","LTC","ETH","XRP"]
    var color:[String:Color] = ["BTC":Color.orange,"LTC":Color.yellow,"ETH":Color.blue,"XRP":Color.red]
    @EnvironmentObject var context:ContextData
    var activeCurrency:Bool{
        return self.context.selectedCurrency != nil
    }
    
    var mainView:some View{
        ScrollView(.vertical,showsIndicators:false){
            LazyVStack(alignment: .center, spacing: 15) {
                Spacer().frame(height: 50)
                self.PriceCards
                LatestTweets(currency: "all")
                self.NewsSection
                CryptoMarket(heading: "Popular Coins",srt:"d",order:.desc)
                CryptoMarket(heading: "Biggest Gainer", srt: "pc",order: .desc,cardSize: CardSize.small)
                CryptoMarket(heading: "Biggest Losers", srt: "pc",order: .incr,cardSize: CardSize.small)
                Spacer(minLength: 200)
            }
        }.zIndex(1)
    }
    
    var body: some View {
        ZStack(alignment: .center){
            mainBGView.zIndex(0)
            if self.showMainView{
                self.mainView
            }            
            if let asset = self.context.selectedCurrency{
                self.CurrencyViewGetter(asset: asset, height: totalHeight * 0.3)
            }else if let symb = self.context.selectedSymbol{
                self.CurrencyViewGetter(name: symb, height: totalHeight * 0.3)
            }
            
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
            
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: self.context.selectedCurrency?.name) { newValue in
            print("Currency choosen is : ",newValue)
        }
    }
}

extension HomePage{
    
    func closeNews(){
        if self.context.selectedNews != nil{
            withAnimation(.easeInOut(duration: 0.5)) {
                self.context.selectedNews = nil
            }
        }
    }
    
    var showMainView:Bool {
        return self.context.selectedNews == nil && self.context.selectedCurrency == nil
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
    
    var PriceCards:some View{
//        ScrollView(.horizontal, showsIndicators: false){
        Container(heading: "Tracked Assets", width: totalWidth, ignoreSides: true) { w in
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack(alignment: .center, spacing: 10){
                    ForEach(Array(self.currencies.enumerated()),id:\.offset) { _currency in
                        let currency = _currency.element
                        let idx = _currency.offset
                        let pad_al:Edge.Set = idx == 0  ? .leading : .trailing
                        let pad_val:CGFloat = idx == 0 || idx == self.currencies.count - 1 ? 10 : 0
                        PriceCard(currency: currency,color: self.color[currency] ?? .white,font_color: .white).padding(pad_al,pad_val)
                    }
                }
            }
        }
//        }
    }
    
    
    var NewsSection:some View{
        return RecentNewsCarousel(heading: "News") { currency in
            guard let curr = currency as? String  else {return AnyView(Color.clear)}
            return AnyView(NewsCardCarousel(currency: [curr],size: .init(width: totalWidth, height: totalHeight * 0.65))
            )
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
