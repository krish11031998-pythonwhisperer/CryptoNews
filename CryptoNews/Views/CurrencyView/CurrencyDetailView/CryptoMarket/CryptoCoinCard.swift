//
//  CryptoCoinCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarketCard:View{
    var data:CoinGeckoMarketData
    var size:CGSize
    var rank:Int
    init(data:CoinGeckoMarketData,size:CGSize = CardSize.slender,rank:Int){
        self.data = data
        self.size = size
        self.rank = rank
    }
    
    @ViewBuilder func card(size:CGSize) -> some View{
        switch(self.size){
        case CardSize.slender:
            self.slenderCard(size: size)
        case CardSize.small:
            self.smallCard(size: size)
        default:
            Color.clear
        }
    }
    
    
    @ViewBuilder func chartView(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        
        
        if let chartData = self.data.sparkline_in_7d?.price,chartData.count > 10{
            let chartData = chartData.compactMap({$0})
            let len = chartData.count - 10
            CurveChart(data: Array(chartData[len...]),interactions: false,size: size,bg: Color.clear)
        }else{
            Color.clear.frame(width: w, height: h * 0.5 - 10, alignment: .center)
        }
    }
    
    func smallCard(size:CGSize) ->  some View{
        let w = size.width
        let h = size.height
        return VStack(alignment: .leading, spacing: 2.5) {
            HStack(alignment: .center, spacing: 5) {
                CurrencySymbolView(url: self.data.image, size: .small, width: w * 0.2)
                Spacer()
                self.chartView(size: .init(width: w * 0.5, height: h * 0.75))
            }.frame(width: w, height: h * 0.5, alignment: .center).padding(.top,5)
            MainText(content: self.data.symbol?.uppercased() ?? "BTC", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
            MainText(content: convertToDecimals(value: self.data.current_price), fontSize: 13, color: .gray, fontWeight: .semibold, style: .monospaced)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        
    }
    
    
    func slenderCard(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        return VStack(alignment: .leading, spacing: 10) {
            self.headerView(size: .init(width: w, height: h * 0.3 - 5))
            self.chartView(size: .init(width: w * 0.95, height: h * 0.45 - 10))
            self.footerView(size: .init(width: w, height: h * 0.25 - 5))
        }
        .frame(width: size.width, height: size.height, alignment: .leading)
    }
    
    var body: some View{
        let s_width = self.size.width - 5
        let s_height = self.size.height - 5
       return GeometryReader{g in
            let s = g.frame(in: .local).size
            self.card(size: s)
        }.padding(15)
        .frame(width: s_width, height: s_height , alignment: .leading)
        .background(BlurView(style: .dark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}

extension CryptoMarketCard{
    func headerView(size:CGSize) -> AnyView{
        return AnyView(
            //            VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5){
                    MainText(content: self.data.name ?? "Name", fontSize: 20,color: .white, fontWeight: .semibold)
                    MainText(content: convertToMoneyNumber(value: self.data.current_price), fontSize: 17.5,color: .white)
                }
                Spacer()
                MainText(content: "#\(self.rank)", fontSize: 10, color: .white, fontWeight: .medium)
                    .padding(7.5)
                    .background(Color.black)
                    .clipShape(Circle())
                
            }.padding(5)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
        )
    }
    
    func footerEl(key:String,value:String) -> some View{
        return VStack(alignment: .leading, spacing: 2.5) {
            MainText(content: key, fontSize: 10, color: .white, fontWeight: .semibold)
            MainText(content: value, fontSize: 12, color: .white, fontWeight: .regular)
        }
//        .background(Color.yellow)
    }
    
    func footerView(size:CGSize) -> AnyView{
        return AnyView(
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: size.width * 0.5 - 10), spacing:10, alignment: .topLeading),GridItem(.adaptive(minimum: 100, maximum: size.width * 0.4 - 10), spacing:10, alignment: .topLeading)],alignment: .leading,spacing:10){
                self.footerEl(key: "Market Cap", value: "\(convertToMoneyNumber(value: self.data.market_cap))")
                self.footerEl(key: "Total Volume", value: "\(convertToMoneyNumber(value: self.data.total_volume))")
                self.footerEl(key: "Circulating Supply", value: "\(convertToMoneyNumber(value: self.data.circulating_supply))")
                self.footerEl(key: "Max Supply", value: "\(convertToMoneyNumber(value: self.data.max_supply))")
            }.frame(width: size.width, height: size.height, alignment: .center)
//            .background(Color.red)
        )
    }
}


//struct CryptoCoinCard_Previews: PreviewProvider {
//    static var previews: some View {
//        CryptoCoinCard()
//    }
//}
