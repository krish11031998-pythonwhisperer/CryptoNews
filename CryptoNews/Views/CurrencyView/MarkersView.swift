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
    var current_val:Float
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
    
    var headerOrder:[String] = ["Value (now)","Profit","Percent"]
    
    var headerValues:[String:Float]{
        let val_bought = self.data.value_usd
        let val_now = Float(self.data.crypto_coins) * self.data.current_val
        let profit = val_now - val_bought
        return ["Value (now)":val_now,"Profit":profit,"Percent": (profit/val_bought) * 100]
    }
    
    func percentChangeView(value:Float) -> some View{
        let img = value > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
        let color = value > 0 ? Color.green : value < 0 ? Color.red : Color.clear
        let view = HStack(alignment: .center) {
            Image(systemName: img)
                .resizable()
                .frame(width: 15, height: 15, alignment: .center)
                .foregroundColor(.white)
            MainText(content: convertToDecimals(value: value) + "%", fontSize: 12, color: .white, fontWeight: .bold,style: .monospaced)
        }.padding()
        .background(color)
        .clipContent(clipping: .roundClipping)
        
        return view
    }
    
    func Header(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 10){
            ForEach(self.headerOrder,id: \.self) { key in
                if let value = self.headerValues[key]{
                    if key == "Percent"{
                        Group{
                            Spacer()
                            self.percentChangeView(value: value)
                        }
                        
                    }else{
                        MainSubHeading(heading: key, subHeading: key == "Coin(s)" ? convertToDecimals(value:abs(value)) : convertToMoneyNumber(value: abs(value)), headingSize: 12, subHeadingSize: 20,subHeadColor: key == "Profit" ? value < 0 ? .red : .green : .white)
                    }
                    
                } 
            }
        }.aspectRatio(contentMode: .fit)
        .frame(width: size.width,alignment: .leading)
        .frame(maxHeight:size.height)
    }
    
    func transactionDetails(size:CGSize) -> some View{
        return HStack(alignment: .top, spacing: 20){
            MainSubHeading(heading: "Total gas fee", subHeading: convertToMoneyNumber(value: self.data.fee), headingSize: 12, subHeadingSize: 15)
            MainSubHeading(heading: "Total fee", subHeading: convertToMoneyNumber(value: self.data.fee), headingSize: 12, subHeadingSize: 15)
            MainSubHeading(heading: "Total Buy Txns", subHeading: "\(self.data.totalBuys ?? 0)", headingSize: 12, subHeadingSize: 15)
        }
    }
    
    func transactionHistoryCard(txn:PortfolioData,size:CGSize) -> some View{
        let percent:Float = -(txn.value_usd - data.totalfee)/data.totalfee
        return VStack(alignment: .leading, spacing: 5){
            HStack(alignment: .bottom, spacing: 10){
                MainSubHeading(heading: txn.type?.capitalized  ?? "Coins", subHeading: convertToDecimals(value: Float(txn.crypto_coins)), headingSize: 12, subHeadingSize: 15)
                MainText(content: convertToDecimals(value: percent * 100), fontSize: 12,color: percent < 0 ? .red : .green)
            }
            MainSubHeading(heading: "Value", subHeading: convertToMoneyNumber(value: txn.totalfee), headingSize: 12, subHeadingSize: 15)
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
