//
//  ChartCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct PriceCard: View {
//    @StateObject var asset_api:AssetAPI
//    @State var prices:[AssetData] = []
//    @State var selected:Int = -1
    var coin:CoinData
    @EnvironmentObject var context:ContextData
    var size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.4)
    let font_color:Color
    var alternativeView:Bool

    init(coin:CoinData,size:CGSize? = nil,font_color:Color = .white,alternativeView:Bool = false){
        self.coin = coin
        if let safeSize = size{
            self.size = safeSize
        }
        self.font_color = alternativeView && font_color == .white ? .black : font_color
        self.alternativeView = alternativeView
    }
    
    
    var prices:[Float]{
        self.coin.Sparkline
    }
    
    func headingSize(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: self.coin.Name, fontSize: 20,color: font_color,fontWeight: .regular)
            Spacer()
            MainText(content: self.coin.Symbol, fontSize: 20,color: font_color,fontWeight: .semibold)
        }.frame(width: w, height: h, alignment: .leading)
    }
    
    func PriceView(size:CGSize) -> some View{
        let price = self.coin.Price.ToMoney()
        let percentage = "\(self.coin.Change.ToDecimals())%"
        let fontColor:Color = self.alternativeView ? .black : .white
        return HStack(alignment: .center, spacing: 10){
            
//            CurrencySymbolView(url: self.coin.iconUrl, size: .small, width: size.width * 0.2)
            ImageView(url: self.coin.iconUrl, width: size.width * 0.2, height: size.width * 0.2, contentMode: .fill, alignment: .center, clipping: .circleClipping)
            Spacer()
            VStack(alignment: .trailing, spacing: 2.5) {
                MainText(content: percentage, fontSize: 10, color: fontColor, fontWeight: .semibold)
                MainText(content: price, fontSize: 20, color: fontColor, fontWeight: .semibold)
                
            }
        }.frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
    func topView(w:CGFloat,h:CGFloat) -> some View{
        let chartShade:Color? = self.alternativeView ? nil : Color.white
        
        return VStack(alignment: .leading, spacing: 0) {
            self.headingSize(w: w, h: h * 0.15)
            CurveChart(data: self.prices.compactMap({$0}), interactions: false, size: .init(width: w, height: h * 0.6), bg: .clear,lineColor: chartShade, chartShade: false)
            PriceView(size: .init(width: w, height: h * 0.25))
        }
        .frame(width:w,height: h)
    }
    
    func footerView(w:CGFloat,h:CGFloat) -> some View{
        let currencyTotalPrice = self.context.totalForCurrency(asset: self.coin.Symbol) * (self.coin.Price)
        let view = LazyVStack(alignment: .leading, spacing: 3.5) {
            MainText(content: "Balance", fontSize: 10,color: .black,fontWeight: .semibold)
            MainText(content: currencyTotalPrice.ToMoney(),fontSize: 20, color: .black, fontWeight: .bold)
        }
        .padding(.bottom,10)
        .frame(width:w,height: h,alignment: .bottomLeading)
        
        return view
    }
    
    var bgColor:some View{
        VStack(alignment: .leading, spacing: 0) {
            Color.mainBGColor.frame(width: size.width, height: size.height * 0.8, alignment: .center)
            Color.white.frame(width: size.width, height: size.height * 0.2, alignment: .center)
        }
    }
    
    var mainView:some View{
        let w = size.width - 30
        let h = size.height - 30
        
        return LazyVStack(alignment: .leading, spacing: 10) {
            self.topView(w: w, h: h * 0.8)
            self.footerView(w: w, h: h * 0.2)
        }
        .padding()
        .frame(width: size.width, height: size.height, alignment: .center)
        .background(bgColor)
        .clipContent(clipping: .roundClipping)
        
    }
    
    var alternativeMainView:some View{
        let w = size.width - 30
        let h = size.height - 30
        return self.topView(w: w, h: h)
            .padding()
            .frame(width: size.width, height: size.height, alignment: .center)
            .background(mainLightBGView)
            .clipContent(clipping: .roundClipping)
        
    }
    
    @ViewBuilder var mainBody:some View{
        if self.alternativeView{
            self.alternativeMainView
        }else{
            self.mainView
        }
    }
    
    var body: some View {
        self.mainBody
            .buttonify {
                DispatchQueue.main.async {
                    self.context.selectedCurrency = self.coin
                }
            }
    }
}

//struct PriceCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PriceCard(currency: "BTC")
//            .previewLayout(.sizeThatFits)
//            .background(Color.black)
//    }
//}
