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
//    var current_val:Float
    var profit:Float
    var fee:Float
    var totalfee:Float
    var totalBuys:Int?
    var currentPrice:Float
    var txns:[PortfolioData]?
}

struct MarkerMainView:View{
    var data:PortfolioData
    var size:CGSize
    
    init(data:PortfolioData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.4)){
        self.data = data
        self.size = size
    }
    
    var headerOrder:[String] = ["Value (now)","Profit","Percent"]
    
    var headerValues:[String:Float]{
        let val_bought = self.data.value_usd
        return ["Coin(s)":Float(self.data.crypto_coins),"Value (now)":self.data.value_usd,"Profit":self.data.profit,"Percent": (self.data.profit/self.data.value_usd) * 100]
    }
    
    func percentChangeView(value:Float,type:String = "large") -> some View{
        let img = value > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
        let color = value > 0 ? Color.green : value < 0 ? Color.red : Color.clear
        let imgSize:CGFloat = type == "large" ? 15 : 10
        let textSize:CGFloat = type == "large" ? 12 : 9
        let padding:CGFloat = type == "large" ? 15 : 7.5
        let view = HStack(alignment: .center) {
            Image(systemName: img)
                .resizable()
                .frame(width: imgSize, height: imgSize, alignment: .center)
                .foregroundColor(.white)
            MainText(content: convertToDecimals(value: value) + "%", fontSize: textSize, color: .white, fontWeight: .bold,style: .monospaced)
        }.padding(padding)
        .background(color)
        .clipContent(clipping: .roundClipping)
        
        return view
    }
    
    func Header(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 10){
            ForEach(self.headerOrder,id: \.self) { key in
                if let value = self.headerValues[key]{
                    if key == "Percent"{
                        Spacer()
                        self.percentChangeView(value: value)
                    }else{
                        MainTextSubHeading(heading: key, subHeading: key == "Coin(s)" ? convertToDecimals(value:abs(value)) : convertToMoneyNumber(value: abs(value)), headingSize: 12, subHeadingSize: 20,subHeadColor: key == "Profit" ? value < 0 ? .red : .green : .white)
                    }
                    
                }
            }
        }
        .frame(width: size.width,alignment: .leading)
        .frame(maxHeight:size.height)
    }
    
    func transactionDetails(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 20){
            MainTextSubHeading(heading: "Total gas fee", subHeading: convertToMoneyNumber(value: self.data.fee), headingSize: 12, subHeadingSize: 15)
            MainTextSubHeading(heading: "Total fee", subHeading: convertToMoneyNumber(value: self.data.fee), headingSize: 12, subHeadingSize: 15)
            MainTextSubHeading(heading: "Total Buy Txns", subHeading: "\(self.data.totalBuys ?? 0)", headingSize: 12, subHeadingSize: 15)
        }.frame(width: size.width, height: size.height, alignment: .leading)
    }
    
    func transactionHistoryCard(txn:PortfolioData,size:CGSize) -> some View{
        let percent:Float =  (Float(txn.crypto_coins) * self.data.currentPrice - txn.totalfee)/txn.totalfee
        let color:Color = percent < 0 ? .red : .green
        return VStack(alignment: .leading, spacing: 2.5){
            MainTextSubHeading(heading: txn.type?.capitalized  ?? "Coins", subHeading: convertToDecimals(value: Float(txn.crypto_coins)), headingSize: 12, subHeadingSize: 15)
            MainTextSubHeading(heading: "Value", subHeading: convertToMoneyNumber(value: txn.value_usd), headingSize: 12, subHeadingSize: 15)
            self.percentChangeView(value: percent * 100,type: "small").padding(.vertical,5)
            
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
                    self.transactionHistoryCard(txn: data, size: .init(width: size.width * 0.45, height: size.height))
                }
            }
        }
    }
    
    var body:some View{
        Container(heading: "Assets", headingColor: .white,headingSize: 20, width: self.size.width, horizontalPadding: 15, verticalPadding: 15) { w in
            let h = self.size.height - 20
            self.Header(size: .init(width: w, height: h * 0.2))
            self.transactionHistory(size: .init(width: w, height: h * 0.4))
        }.basicCard()
            .borderCard()
    }
}
