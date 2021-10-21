//
//  MarkersView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 18/09/2021.
//

import Foundation
import SwiftUI

struct PortfolioData{
    var type:String?
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
        return MainSubHeading(heading: heading, subHeading: subText, headingSize: 12, subHeadingSize: large ? 20 : 15, headingFont: .heading, subHeadingFont: .normal)
//        return VStack(alignment: .leading, spacing: 10){
//            MainText(content: heading, fontSize: 12)
//            MainText(content: subText, fontSize: large ? 20 : 15,fontWeight: .semibold)
//        }.frame(alignment: .leading)
//        .fixedSize(horizontal: false, vertical: true)
    }
    
    func Header(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 10){
            headLineText(heading: "Coin(s)", subText: convertToDecimals(value: Float(self.data.crypto_coins)),large: true)
            headLineText(heading: "Value", subText: convertToDecimals(value: self.data.value_usd),large: true)
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
        let percent:Float = -(txn.value_usd - data.totalfee)/data.totalfee
        return VStack(alignment: .leading, spacing: 5){
            HStack(alignment: .bottom, spacing: 10){
                headLineText(heading: txn.type?.capitalized  ?? "Coins", subText: convertToDecimals(value: Float(txn.crypto_coins)))
                MainText(content: convertToDecimals(value: percent * 100), fontSize: 12,color: percent < 0 ? .red : .green)
            }
            headLineText(heading: "Value", subText: convertToMoneyNumber(value: txn.totalfee))
        }.padding()
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(BlurView(style: .systemThinMaterialDark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func transactionHistory(size:CGSize) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 10){
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
           VStack(alignment: .leading, spacing: 20){
                self.Header(size: .init(width: w, height: h * 0.2))
                self.transactionDetails(size: .init(width: w, height: h * 0.2))
                self.transactionHistory(size: .init(width: w, height: h * 0.4))
            }.padding(.vertical,10)
        })
    }
}

struct MarkerView_Previews:PreviewProvider{
    
    static var previews:some View{
        MarkerMainView(data: .init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1,txns: [.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1),.init(crypto_coins: 1, value_usd: 185.43, fee: 1.36, totalfee: 186.79, totalBuys: 1)]))
    }
}
