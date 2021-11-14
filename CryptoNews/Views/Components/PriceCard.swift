//
//  ChartCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct PriceCard: View {
//    var prices:[Float]
    @StateObject var asset_api:AssetAPI
    @State var prices:[AssetData] = []
    @State var selected:Int = -1
//    @Binding var selected_asset:AssetData?
    @EnvironmentObject var context:ContextData
    var currency:String
    var size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.4)
    var color:Color
    let font_color:Color

    init(currency:String,color:Color = .orange,size:CGSize? = nil,font_color:Color = .white){
        self.color = color
        self.currency = currency
        self._asset_api = StateObject(wrappedValue: .init(currency: currency))
        if let safeSize = size{
            self.size = safeSize
        }
        self.font_color = font_color
    }
    
    func parsePrices(data:AssetData?){
        
        guard let data = data, let timeSeries = data.timeSeries else {return}
        DispatchQueue.main.async {
            self.prices = timeSeries
        }
    }
    
    func updatePrices(){
        self.asset_api.getAssetInfo()
    }
    
    func onAppear(){
        if self.prices.isEmpty && asset_api.data == nil{
            self.asset_api.getAssetInfo()
        }
    }
    
    
    func headingSize(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: self.asset_api.data?.name ?? "No Name", fontSize: 20,color: font_color,fontWeight: .regular)
            Spacer()
            MainText(content: self.currency, fontSize: 20,color: font_color,fontWeight: .semibold)
        }.frame(width: w, height: h, alignment: .leading)
    }
    
    func PriceView(size:CGSize) -> some View{
        let pointData = self.selected >= 0 && self.selected <= self.prices.count - 1 ? self.prices[self.selected] : self.prices.last
        let price = self.asset_api.data?.price?.ToMoney() ?? "0.0"
        let percentage = "\((self.asset_api.data?.percent_change_24h ?? 0.0).ToDecimals())%"
        
        return HStack(alignment: .center, spacing: 10){
            CurrencySymbolView(currency: self.currency, size: .small, width: size.width * 0.2)
            Spacer()
            VStack(alignment: .trailing, spacing: 2.5) {
                MainText(content: percentage, fontSize: 10, color: .white, fontWeight: .semibold)
                MainText(content: price, fontSize: 20, color: .white, fontWeight: .semibold)
                
            }
        }.frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
    func topView(w:CGFloat,h:CGFloat) -> some View{
        LazyVStack(alignment: .leading, spacing: 0) {
            self.headingSize(w: w, h: h * 0.15)
            CurveChart(data: self.prices.compactMap({$0.close}),choosen: self.$selected, interactions: false, size: .init(width: w, height: h * 0.6), bg: .clear,lineColor: .white, chartShade: true)
            PriceView(size: .init(width: w, height: h * 0.25))
        }
        .frame(width:w,height: h)
    }
    
    func footerView(w:CGFloat,h:CGFloat) -> some View{
        LazyVStack(alignment: .leading, spacing: 3.5) {
            MainText(content: "Balance", fontSize: 10,color: .black,fontWeight: .semibold)
            MainText(content: self.asset_api.data?.price?.ToMoney() ?? "No Money", fontSize: 20, color: .black, fontWeight: .bold)
        }
        .padding(.bottom,10)
        .frame(width:w,height: h,alignment: .bottomLeading)
    }
    
    var bgColor:some View{
        VStack(alignment: .leading, spacing: 0) {
            Color.mainBGColor.frame(width: size.width, height: size.height * 0.8, alignment: .center)
            Color.white.frame(width: size.width, height: size.height * 0.2, alignment: .center)
//                .background(Color.white.opacity(0.85))
        }
    }
    
    var chartView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            LazyVStack(alignment: .leading, spacing: 10) {
                self.topView(w: w, h: h * 0.8)
                self.footerView(w: w, h: h * 0.2)
            }
        }
        .padding()
        .frame(width: size.width, height: size.height, alignment: .center)
        .background(bgColor)
        .clipContent(clipping: .roundClipping)
        
    }
    
    var body: some View {
        self.chartView
            .buttonify {
                DispatchQueue.main.async {
                    self.context.selectedCurrency = self.asset_api.data
                }
                
            }
            .onAppear(perform: self.onAppear)
            .onReceive(self.asset_api.$data, perform: self.parsePrices(data:))
        
            
    }
}

struct PriceCard_Previews: PreviewProvider {
    static var previews: some View {
        PriceCard(currency: "BTC")
            .previewLayout(.sizeThatFits)
            .background(Color.black)
    }
}
