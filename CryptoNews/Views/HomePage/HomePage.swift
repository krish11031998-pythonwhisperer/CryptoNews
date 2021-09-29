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
    @State var selectedCurrency:AssetData? = nil
//    @State var showAsset:Bool = false
    var activeCurrency:Bool{
        return self.selectedCurrency != nil
    }
    
    var body: some View {
        ZStack(alignment: .center){
            mainBGView.zIndex(0)
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
            if let asset = self.selectedCurrency{
                self.CurrencyView(asset: self.selectedCurrency!, height: totalHeight * 0.3)
            }
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}

extension HomePage{
    
    func closeAsset(){
        if self.selectedCurrency != nil{
            withAnimation(.easeInOut(duration: 0.5)) {
                self.selectedCurrency = nil
            }
        }
    }
    

    
    func CurrencyView(asset:AssetData,height h :CGFloat) -> some View{
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: "\(asset.symbol ?? "CRYPTO")",onClose: self.closeAsset) { w in
                CurrencyDetailView(info: asset,size: .init(width: w, height: h))
            }
        }
        .transition(.slideInOut)
        .padding(.top,50)
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
        .zIndex(2)
    }
    
    var PriceCards:some View{
        ScrollView(.horizontal, showsIndicators: false){
            LazyHStack(alignment: .center, spacing: 10){
                ForEach(self.currencies,id:\.self) { currency in
                    PriceCard(currency: currency,asset: $selectedCurrency,color: self.color[currency] ?? .white,font_color: .white)
                        
                }
            }.padding()
        }
    }
    
    
    var NewsSection:some View{
        return RecentNewsCarousel(heading: "News") { currency in
            guard let curr = currency as? String  else {return AnyView(Color.clear)}
//            return AnyView(RecentNews(currency: curr,ext_h: true))
            return AnyView(NewsCardCarousel(currency: [curr],size: .init(width: totalWidth, height: totalHeight * 0.65)))
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
