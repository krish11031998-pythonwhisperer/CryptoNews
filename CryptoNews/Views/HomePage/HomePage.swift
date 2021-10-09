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
            VStack(alignment: .center, spacing: 15) {
                Spacer().frame(height: 50)
                self.PriceCards
                self.NewsSection
                LatestTweets(currency: "all")
                CryptoMarket()
//                    CryptoYoutube()
                
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
            }
            if let news = self.context.selectedNews, let urlStr = news.url,let url  = URL(string: urlStr){
                WebModelView(url: url, close: self.closeNews)
                    .transition(.slideInOut)
                    .zIndex(2)
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
        }
    }
    
    func CurrencyViewGetter(asset:AssetData,height h :CGFloat) -> some View{
//        ScrollView(.vertical, showsIndicators: false) {
////            Container(heading: "\(asset.symbol ?? "CRYPTO")",onClose: self.closeAsset) { w in
////                CurrencyDetailView(info: asset,size: .init(width: w, height: h))
////            }
//        }
        CurrencyView(info: asset, size: .init(width: totalWidth, height: totalHeight), onClose: self.closeAsset)
//        CurrencyView(asset: asset, height: )
        .transition(.slideInOut)
//        .padding(.top,50)
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
        .zIndex(2)
    }
    
    var PriceCards:some View{
        ScrollView(.horizontal, showsIndicators: false){
            LazyHStack(alignment: .center, spacing: 10){
                ForEach(self.currencies,id:\.self) { currency in
                    PriceCard(currency: currency,color: self.color[currency] ?? .white,font_color: .white)
                }
            }.padding()
        }
    }
    
    
    var NewsSection:some View{
        return RecentNewsCarousel(heading: "News") { currency in
            guard let curr = currency as? String  else {return AnyView(Color.clear)}
//            return AnyView(RecentNews(currency: curr,ext_h: true))
            return AnyView(NewsCardCarousel(currency: [curr],size: .init(width: totalWidth, height: totalHeight * 0.65))
//                            .environmentObject(self.context)
            )
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
