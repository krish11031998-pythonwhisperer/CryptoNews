//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    var currencies:[String] = ["BTC","LTC","ETH"]
    var color:[String:Color] = ["BTC":Color.orange,"LTC":Color.yellow,"ETH":Color.blue]
//    var currencies:[String] = ["BTC"]
//
    @State var selectedCurrency:AssetData? = nil
    var body: some View {
        ZStack(alignment: .center){
            mainBGView
            ScrollView(.vertical,showsIndicators:false){
                VStack(alignment: .center, spacing: 15) {
                    Spacer().frame(height: 50)
                    self.PriceCards
                    self.NewsSection
                    LatestTweets(currency: "all")
                    CryptoMarket()
                    CryptoYoutube()
                    Spacer(minLength: 200)
                }
            }
            if let asset = self.selectedCurrency{
                ScrollView(.vertical, showsIndicators: false) {
                    Container(heading: "\(asset.symbol ?? "CRYPTO")",onClose: self.closeAsset) { w in
                        AnyView(CurrencyDetailView(info: asset,size: .init(width: w, height:   totalHeight * 0.3)))
                    }
                }
                .padding(.top,50)
                .background(mainBGView)
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .bottom))
            }
        }.frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut)
    }
}

extension HomePage{
    
    func closeAsset(){
        if self.selectedCurrency != nil{
            self.selectedCurrency = nil
        }
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
            return AnyView(RecentNews(currency: curr,ext_h: true))
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
