//
//  SingleTransactionView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct SingleTransactionView: View {
    var txn:Transaction
    @State var showMore:Bool = false
    var currentPrice:Float
    var width:CGFloat
    
    init(txn:Transaction,currentPrice:Float,width:CGFloat = totalWidth - 20){
        self.txn = txn
        self.width = width
        self.currentPrice = currentPrice
    }
    
    var body: some View {
        self.mainInnerBody
            .buttonify {
                withAnimation(.easeInOut) {
                    self.showMore.toggle()
                }
            }
    }
}


extension SingleTransactionView{
    
    
    var mainInnerBody:some View{
        VStack(alignment: .leading, spacing: 7.5){
            self.txnHeader
            self.txnSummary
            if self.showMore{
                self.txnMiscDetails
            }
        }.padding()
//            .background(Color.mainBGColor.overlay(BlurView(style: .systemChromeMaterialDark)))
        .frame(width:width,alignment: .topLeading)
        .clipContent(clipping: .roundClipping)
    }
    
    
    var txnPercent:(Float,Color,String){
        let asset_price = self.txn.asset_spot_price ?? 0
        let value:Float = ((self.currentPrice - asset_price)/self.currentPrice) * 100
        let color:Color = value > 0 ? Color.green : Color.red
        let symb = value > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
        return (abs(value),color,symb)
    }
    
    var txnHeader:some View{
        HStack {
            MainText(content: self.txn.TxnType.capitalized, fontSize: 20, color: .white, fontWeight: .regular, style: .normal)
            Spacer()
            MainText(content: self.txn.timeStamp.stringDate(), fontSize: 10, color: .white, fontWeight: .semibold, style: .monospaced)
        }
    }
    
    var percentChangeView:some View{
        HStack(alignment: .center) {
            Image(systemName: self.txnPercent.2)
                .resizable()
                .frame(width: 15, height: 15, alignment: .center)
                .foregroundColor(.white)
            MainText(content: convertToDecimals(value: txnPercent.0) + "%", fontSize: 12, color: .white, fontWeight: .bold,style: .monospaced)
        }.padding()
        .background(self.txnPercent.1)
        .clipContent(clipping: .roundClipping)
    }
    
    var txnSummary:some View{
        HStack {
            MainText(content: convertToDecimals(value: self.txn.asset_quantity), fontSize: 25, color: .white, fontWeight: .regular,style: .monospaced)
            Spacer()
            self.percentChangeView
        }
    }
    
    
    var txnMiscDetails:some View{
        VStack(alignment: .leading, spacing: 10) {
            if let spotPrice = self.txn.asset_spot_price,spotPrice != 0{
                MainSubHeading(heading: "Spot Price", subHeading: convertToMoneyNumber(value: spotPrice), headingSize: 12, subHeadingSize: 14,headingFont: .monospaced,subHeadingFont: .monospaced)
            }
            if let subTotal = self.txn.subtotal, subTotal != 0{
                MainSubHeading(heading: "Sub-Total", subHeading: convertToMoneyNumber(value: subTotal), headingSize: 12, subHeadingSize: 14,headingFont: .monospaced,subHeadingFont: .monospaced)
            }
            if let fee = self.txn.fee, fee != 0{
                MainSubHeading(heading: "Fee", subHeading: convertToMoneyNumber(value: fee), headingSize: 12, subHeadingSize: 14,headingFont: .monospaced,subHeadingFont: .monospaced)
            }
            if let total = self.txn.total_inclusive_price, total != 0{
                MainSubHeading(heading: "Total", subHeading: convertToMoneyNumber(value: total), headingSize: 12, subHeadingSize: 14,headingFont: .monospaced,subHeadingFont: .monospaced)
            }
        }
    }
}

struct SingleTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        SingleTransactionView(txn: .init(time: "2021-09-07 20:25:39.290665 +0000 UTC", type: "buy", asset: "XRP", asset_quantity: 23.243460, asset_spot_price: 4.05, subtotal: 95.00, total_inclusive_price: 100.00, fee: 5.00, memo: "You bought XRP",uid: ""), currentPrice: 1.4)
            .previewLayout(.sizeThatFits)
//            .background(Color.mainBGColor)
    }
}
