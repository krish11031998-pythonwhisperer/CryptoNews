//
//  ChartCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct PriceCard: View {
    @StateObject var coin_api:CGCoinAPI
    @State var selected:Int = -1
    @EnvironmentObject var context:ContextData
    var currency:String
    var size:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.4)
    var color:Color
    let font_color:Color

    init(currency:String,color:Color = .orange,size:CGSize? = nil,font_color:Color = .white){
        self.color = color
        self.currency = currency
        self._coin_api = .init(wrappedValue: .init(currency: currency))
        if let safeSize = size{
            self.size = safeSize
        }
        self.font_color = font_color
    }
    
    var pointData:[Float]{
        guard let sparkline = self.coin_api.data?.market_data?.sparkline_7d?.price else {return []}
        let len = (sparkline.count - 15)
        return Array(sparkline.compactMap({$0})[len...])
    }
    
    func updatePrices(){
        self.coin_api.getCoinData()
    }
    
    func onAppear(){

        if self.coin_api.data == nil{
            self.updatePrices()
        }
    }
    
    var asset:CoinGeckoAsset?{
        return self.coin_api.data
    }
    
    func headingSize(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            if let small = self.asset?.image?.small{
                CurrencySymbolView(url: small, size: .medium, width: w * 0.2)
            }
            MainText(content: self.asset?.symbol?.uppercased() ?? self.currency, fontSize: 20,color: font_color)
        }.frame(width: w, height: h, alignment: .leading)
    }
    
    func PriceView(size:CGSize) -> some View{
        let open = pointData.last ?? 0
        
        return HStack(alignment: .center, spacing: 10){
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 10, height: size.height, alignment: .center)
            VStack(alignment: .leading, spacing: 2){
                MainText(content: "Now", fontSize: 8.5,color: color)
                MainText(content: String(format: "%.2f", open), fontSize: 20,color: color,fontWeight: .bold)
            }.frame(height: size.height, alignment: .leading)
            Spacer()
        }.frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
    var chartView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            LazyVStack(alignment: .leading, spacing: 10){
                self.headingSize(w: w, h: h * 0.15)
                PriceView(size: .init(width: w, height: h * 0.25))
                CurveChart(data: pointData,choosen: self.$selected, interactions: false, size: .init(width: w, height: h * 0.6), bg: .clear, chartShade: true)
            }.frame(width: w, height: h, alignment: .leading)
            
        }
        .basicCard(size: size)
        .onAppear(perform: self.onAppear)
        .buttonify {
            DispatchQueue.main.async {
                print("(DEBUG) choosen data : ",coin_api.data?.symbol)
                self.context.selectedCurrency = self.coin_api.data
            }
        }
    }
    
    var body: some View {
        self.chartView
    }
}

struct PriceCard_Previews: PreviewProvider {
    static var previews: some View {
        PriceCard(currency: "BTC")
            .previewLayout(.sizeThatFits)
    }
}
