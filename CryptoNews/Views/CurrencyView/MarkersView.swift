//
//  MarkersView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 18/09/2021.
//

import Foundation
import SwiftUI

struct PortfolioData{
    var crypto_coins:Double
    var value_usd:Float
    var fee:Float
    var totalfee:Float
    var totalBuys:Int?
    var txns:[PortfolioData]?
}

struct MarkerMainView:View{
    var data:PortfolioData
    var size:CGSize
    
    init(data:PortfolioData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.4)){
        self.data = data
        self.size = size
    }

    func headLineText(heading:String,subText:String,large:Bool = false) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: heading, fontSize: 12)
            MainText(content: subText, fontSize: large ? 20 : 15,fontWeight: .semibold)
        }.frame(alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func Header(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 10){
            headLineText(heading: "Coin(s)", subText: "\(self.data.crypto_coins)",large: true)
            headLineText(heading: "Value", subText: String(format:"$%.1f",self.data.value_usd),large: true)
        }.aspectRatio(contentMode: .fit)
        .frame(width: size.width,alignment: .leading)
        .frame(maxHeight:size.height)
    }
    
    func transactionDetails(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 20){
            headLineText(heading: "Total gas fee", subText: convertToMoneyNumber(value: self.data.fee))
            headLineText(heading: "Total fee", subText: convertToMoneyNumber(value: self.data.fee))
            headLineText(heading: "Total Buy Txns", subText: "\(self.data.totalBuys ?? 0)")
        }
    }
    
    func transactionHistoryCard(txn:PortfolioData,size:CGSize) -> some View{
        return VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .bottom, spacing: 0.5){
                headLineText(heading: "Coins", subText: "\(txn.crypto_coins)")
                MainText(content: "0.3%", fontSize: 12,color: .red)
            }
            headLineText(heading: "Value", subText: convertToMoneyNumber(value: self.data.fee))
        }.padding()
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(BlurView(style: .systemThinMaterialDark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func transactionHistory(size:CGSize) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10){
                ForEach(Array((self.data.txns ?? []).enumerated()), id:\.offset) { _data in
                    let data = _data.element
//                    let idx = _data.offset
                    self.transactionHistoryCard(txn: data, size: .init(width: size.width * 0.45, height: size.height))
                }
            }
        }
    }
    
    var body:some View{
        ChartCard(header: "Assets", size: size, insideView: { w, h in
            let view = VStack(alignment: .leading, spacing: 20){
                self.Header(size: .init(width: w, height: h * 0.2))
                self.transactionDetails(size: .init(width: w, height: h * 0.2))
                self.transactionHistory(size: .init(width: w, height: h * 0.4))
            }.padding(.vertical,10)
            return AnyView(view)
        })
    }
}

struct MarkerView_Previews:PreviewProvider{
    
    static var previews:some View{
        MarkerMainView(data: .init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1,txns: [.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1)]))
    }
}
