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
    
    
    func PriceView(size:CGSize) -> some View{
        let pointData = self.selected >= 0 && self.selected <= self.prices.count - 1 ? self.prices[self.selected] : self.prices.last
        let open = pointData?.open ?? 0
        let close = pointData?.close ?? 0
        
        return HStack(alignment: .center, spacing: 10){
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 10, height: size.height, alignment: .center)
            VStack(alignment: .leading, spacing: 2){
                MainText(content: "Open", fontSize: 8.5,color: color)
                MainText(content: String(format: "%.2f", open), fontSize: 20,color: color,fontWeight: .bold)
                MainText(content: "Close", fontSize: 8.5,color: font_color)
                MainText(content: String(format: "%.2f", close), fontSize: 15,color: font_color)
            }.frame(height: size.height, alignment: .leading)
            Spacer()
        }.frame(width: size.width, height: size.height, alignment: .bottom)
    }
    
    var chartView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            LazyVStack(alignment: .leading, spacing: 10){
                MainText(content: self.currency, fontSize: 20,color: font_color)
                PriceView(size: .init(width: w, height: h * 0.25))
                CurveChart(data: self.prices.compactMap({$0.close}),choosen: self.$selected, interactions: false, size: .init(width: w, height: h * 0.6), bg: .clear, chartShade: true)
            }.frame(width: w, height: h, alignment: .leading)
            
        }.padding()
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        .onAppear(perform: self.onAppear)
        .onReceive(self.asset_api.$data, perform: self.parsePrices(data:))
    }
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.async {
                self.context.selectedCurrency = self.asset_api.data
            }
            
        }, label: {
            self.chartView
        }).springButton()
        
            
    }
}

struct PriceCard_Previews: PreviewProvider {
    static var previews: some View {
        PriceCard(currency: "BTC")
            .previewLayout(.sizeThatFits)
    }
}
