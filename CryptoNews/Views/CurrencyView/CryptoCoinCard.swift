//
//  CryptoCoinCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarketCard:View{
    var data:CoinMarketData
    var size:CGSize
    var rank:Int
    init(data:CoinMarketData,size:CGSize = .init(width: totalWidth * 0.5 - 30, height: totalHeight * 0.3),rank:Int){
        self.data = data
        self.size = size
        self.rank = rank
    }
    
    func card(size:CGSize) -> some View{
        let w = size.width - 20
        let h = size.height - 20
        return VStack(alignment: .leading, spacing: 10) {
            self.headerView(size: .init(width: w, height: h * 0.3 - 5))
            if let chartData = self.data.timeSeries{
                CurveChart(data: chartData.compactMap({$0.p ?? nil}),interactions: false,size: .init(width: w * 0.95, height: h * 0.45 - 10),bg: Color.clear)
            }else{
                Color.clear.frame(width: w, height: h * 0.5 - 10, alignment: .center)
            }
            self.footerView(size: .init(width: w, height: h * 0.25 - 5))
        }.padding(10)
        .frame(width: size.width, height: size.height, alignment: .leading)
        .background(BlurView(style: .dark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
    
    var body: some View{
        GeometryReader{g in
            let s = g.frame(in: .local).size
            self.card(size: s)
            
        }.padding(15)
        .frame(width: self.size.width, height: self.size.height , alignment: .leading)
        
    }
}

extension CryptoMarketCard{
    func headerView(size:CGSize) -> AnyView{
        return AnyView(
            //            VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5){
                    MainText(content: self.data.n ?? "Name", fontSize: 20,color: .white, fontWeight: .semibold)
                    MainText(content: convertToMoneyNumber(value: self.data.p), fontSize: 17.5,color: .white)
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
                self.footerEl(key: "Influence", value: "\(convertToMoneyNumber(value: self.data.d))%")
                self.footerEl(key: "Interest", value: "\(convertToMoneyNumber(value: self.data.ss)) ")
                self.footerEl(key: "Sentiment", value: "\(convertToMoneyNumber(value: self.data.as)) out of 5")
                self.footerEl(key: "Dominance", value: "\(convertToMoneyNumber(value: self.data.sd))%")
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
