//
//  CurrencyAssetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct TransactionDetailsView: View {
    @Namespace var animation
    var transactions:[Transaction]
    var currency:String
    var currencyCurrentPrice:Float
    @State var txnType:String = "all"
    @EnvironmentObject var context:ContextData
    @Binding var close:Bool
    var width:CGFloat
    
    init(txns:[Transaction],currency:String,currencyCurrentPrice:Float,width:CGFloat = totalWidth,close:Binding<Bool>? = nil){
        self.transactions = txns
        self.currency = currency
        self.width = width
        self._close = close ?? .constant(false)
        self.currencyCurrentPrice = currencyCurrentPrice
    }
    
    var selectedTransaction:[Transaction]{
        return self.txnType != "all" ? self.transactions.filter({$0.type == self.txnType}) : self.transactions
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            self.SummaryView
            Container(heading: "Transaction History", headingColor: .white, headingDivider: false, headingSize: 20, width: self.width, ignoreSides: true, horizontalPadding: 0, verticalPadding: 0) { _ in
                self.TxnTypesView
                ForEach(Array(self.selectedTransaction.enumerated()),id:\.offset) { _txn in
                    let txn = _txn.element
                    SingleTransactionView(txn: txn, currentPrice: self.currencyCurrentPrice,width: width)
                }
            }.padding(.top,10)
            TabButton(width: width, height: 50, title: "Add Txn", textColor: .white) {
                if !self.context.addTxn{
                    self.context.addTxn.toggle()
                }
                if self.context.selectedSymbol != self.currency{
                    self.context.selectedSymbol = self.currency
                }
            }
        }.padding(.bottom,150).frame(width: width, alignment: .topLeading)
//        .preference(key: AddTxnUpdatePreference.self, value: self.context.addTxn)
    }
}


extension TransactionDetailsView{
    func onClose(){
        withAnimation(.easeInOut) {
            self.close.toggle()
        }
    }
    
    var SummaryHeadingView:some View{
        HStack(alignment: .center, spacing: 10) {
            CurrencySymbolView(currency: self.currency, size: .medium, width: 50)
            MainText(content: "\(self.currency)", fontSize: 35, color: .white, fontWeight: .medium, style: .normal)
        }.frame(width: width, alignment: .leading)
    }
    
    @ViewBuilder func AssetSummaryVal(key:String) -> some View{
        if let value = self.AssetHeadValue[key]{
            let val = key == "Txns" ? "\(value)" : convertToMoneyNumber(value: value)
            let color:Color = key == "Profit" ? value > 0 ? .green  : .red : .white
            MainSubHeading(heading: key, subHeading: val, headingSize: 12, subHeadingSize: 15, headingFont: .normal, subHeadingFont: .normal, headColor: .gray, subHeadColor: color,alignment: .center)
        }else{
            Color.clear
        }
    }
    
    func AssetSummaryInfo(w:CGFloat) -> some View{
        InfoGrid(info: self.AssetHeadKeys, width: w, viewPopulator: self.AssetSummaryVal(key:))
    }
    
    var SummaryView:some View{
        VStack(alignment: .leading, spacing: 10){
            let w = width - 30
            
            self.SummaryHeadingView
            MainSubHeading(heading: "Coin(s)", subHeading: "\(convertToDecimals(value: self.totalCoins))", headingSize: 13, subHeadingSize: 36, headingFont: .normal, subHeadingFont: .normal,alignment: .center)
                .frame(width: w, alignment: .center)
            self.AssetSummaryInfo(w: w)
        }.padding(15)
        .frame(width: width, alignment: .leading)
        .background(Color.mainBGColor.overlay(BlurView(style: .systemChromeMaterialDark)))
        .clipContent(clipping: .roundClipping)
    }
    
    var TxnTypesView:some View{
        let type = ["all","buy","sell","send","recieve"]
        return HStack(alignment: .center, spacing: 10) {
            ForEach(Array(type.enumerated()), id:\.offset){ _type in
                let type = _type.element                
                VStack(alignment: .center, spacing: 2.5) {
                    MainText(content: type.capitalized, fontSize: 15, color: .white, fontWeight: .semibold)
                    if self.txnType == type{
                        RoundedRectangle(cornerRadius: 20).fill(Color.mainBGColor).frame(height: 5, alignment: .center)
                            .matchedGeometryEffect(id: "highlight", in: self.animation)
                    }else{
                        RoundedRectangle(cornerRadius: 20).fill(Color.clear).frame(height: 5, alignment: .center)
                    }
                }
                .buttonify {
                    if self.txnType != type{
                        self.txnType = type
                    }
                }
                
            }
        }.padding(.vertical,10).frame(width: self.width, alignment: .topLeading)
    }
    
    var totalBoughtValue:Float{
        return self.transactions.reduce(0, {$0 + $1.total_inclusive_price * ($1.type == "sell" ? -1 : 1)})
    }
    
    var currentValue:Float{
        return self.totalCoins * self.currencyCurrentPrice
    }
    
    var profit:Float{
        return self.currentValue - self.totalBoughtValue
    }
    
    var totalCoins:Float{
        return self.transactions.reduce(0, {$0 + $1.asset_quantity * ($1.type == "sell" ? -1 : 1)})
    }
    
    var totalFees:Float{
        return self.transactions.reduce(0, {$0 + $1.fee})
    }
    
    var AssetHeadKeys:[String]{
        return ["Value (bought)","Value (now)","Profit","Fees","Txns"]
    }
    
    var AssetHeadValue:[String:Float]{
        return ["Value (bought)":self.totalBoughtValue,"Value (now)":self.currentValue,"Profit":self.profit,"Fees":self.totalFees,"Txns": Float(self.transactions.count)]
    }
    
}

struct CurrencyDetailTester:View{
    @StateObject var TAPI:TransactionAPI = .init()
    
    func onAppear(){
        self.TAPI.loadTransaction()
    }
    
    var body: some View{
        Container(heading: "Transactions", width: totalWidth) { w in
            TransactionDetailsView(txns: self.TAPI.transactions.filter({$0.asset == "litecoin"}),currency: "LTC",currencyCurrentPrice: 500,width: w)
        }.onAppear(perform: self.onAppear)
            .padding(.top,50)
    }
}

struct CurrencyAssetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CurrencyDetailTester()

        }
        .background(Color.mainBGColor)
        .edgesIgnoringSafeArea(.all)
    }
}
