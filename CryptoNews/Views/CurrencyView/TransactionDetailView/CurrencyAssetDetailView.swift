//
//  CurrencyAssetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct TransactionDetailsView: View {
    @Namespace var animation
    var txns:[Transaction]
    var currency:String
    var currencyCurrentPrice:Float
    @State var txnType:String = "all"
    @EnvironmentObject var context:ContextData
    @State var idx:Int = 5
    @Binding var close:Bool
    var width:CGFloat
    
    init(txns:[Transaction],currency:String,currencyCurrentPrice:Float,width:CGFloat = totalWidth,close:Binding<Bool>? = nil){
        self.txns = txns
        self.currency = currency
        self.width = width
        self._close = close ?? .constant(false)
        self.currencyCurrentPrice = currencyCurrentPrice
    }
    
    var transactions:[Transaction]{
        self.txnType != "all" ? self.txns.filter({$0.type == self.txnType}) : self.txns
    }
        
    var transactionList:some View{
        AnimatedListView(data: self.transactions) { txn in
            if let safeTxn = txn as? Transaction{
                SingleTransactionView(txn: safeTxn, currentPrice: self.currencyCurrentPrice, width: self.width)
            }
        }.basicCard()
    }
    

    var body: some View {
        self.SummaryView
//        self.SummaryDetailView
        self.CryptoSummaryView
        self.TxnTypesView
        self.transactionList
        TabButton(width: width, height: 50, title: "Add Txn", textColor: .white) {
            if !self.context.addTxn{
                self.context.addTxn.toggle()
            }
            if self.context.selectedSymbol != self.currency{
                self.context.selectedSymbol = self.currency
            }
        }.animatedAppearance(idx: self.transactions.count)
    }
}


extension TransactionDetailsView{
    func onClose(){
        withAnimation(.easeInOut) {
            self.close.toggle()
        }
    }
    
    func SummaryHeadingView(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            CurrencySymbolView(currency: self.currency, size: .medium, width: 50)
            MainText(content: "\(self.currency)", fontSize: 35, color: .white, fontWeight: .medium, style: .normal)
        }.frame(width: w, alignment: .leading)
    }
    
    @ViewBuilder func AssetSummaryVal(key:String) -> some View{
        if let value = self.AssetHeadValue[key]{
            let val = key == "Txns" ? "\(value)" : convertToMoneyNumber(value: value)
            let color:Color = key == "Profit" ? value > 0 ? .green  : .red : .white
            MainTextSubHeading(heading: key, subHeading: val, headingSize: 12, subHeadingSize: 15, headingFont: .normal, subHeadingFont: .normal, headColor: .gray, subHeadColor: color,alignment: .center)
        }else{
            Color.clear
        }
    }
    
    var SummaryView:some View{
        Container(width: self.width, horizontalPadding: 15, verticalPadding: 15, orientation: .vertical) { w in
            CurrencySymbolView(currency: self.currency, size: .medium, width: 50)
                .frame(width: w, alignment: .topLeading)
            Spacer()
            HStack(alignment: .bottom, spacing: 10) {
                MainText(content: self.currency, fontSize: 25, color: .white, fontWeight: .semibold)
                Spacer()
                MainTextSubHeading(heading: "Coin(s)", subHeading: "\(convertToDecimals(value: self.totalCoins))",headingSize: 15, subHeadingSize: 25, headColor: .gray,subHeadColor: .white,alignment: .center)
                    .aspectRatio(contentMode: .fit)
            }.frame(width: w, alignment: .center)
        }
        .frame(width: self.width, height: totalHeight * 0.25, alignment: .center)
        .basicCard(background:AnyView(mainLightBGView))
    }
    
    
    var CryptoSummaryView:some View{
        let keyValue:[String:Float] = ["Invested":self.totalBoughtValue,"Now":self.currentValue,"Profit":self.profit]
        return Container(width: self.width) { _ in
            ForEach(keyValue.keys.sorted(),id:\.self) { key in
                if let value = keyValue[key]{
                    MoneyTextView(value: value,size: 20,coloredText: key == "Profit")
                        .makeAdjacentView(position: .top) {
                            MainText(content: key, fontSize: 17.5, color: .white, fontWeight: .medium)
                                .maskView {
                                    Color.mainBGColor
                                }
                        }
                }
            }
        }.basicCard()
    }
    
    var TxnTypesView:some View{
        let types = ["all","buy","sell","send","recieve"]
        return Container(width:self.width,orientation:.horizontal){ _ in
            ForEach(Array(types.enumerated()), id:\.offset){ _type in
                let type = _type.element
                let idx = _type.offset
                VStack(alignment: .center, spacing: 2.5) {
                    MainText(content: type.capitalized, fontSize: 15, color: .white, fontWeight: .semibold)
                    if self.txnType == type{
                        RoundedRectangle(cornerRadius: 20).fill(Color.mainBGColor).frame(height: 5, alignment: .center)
                            .matchedGeometryEffect(id: "highlight", in: self.animation)
                    }else{
                        RoundedRectangle(cornerRadius: 20).fill(Color.clear).frame(height: 5, alignment: .center)
                    }
                }.aspectRatio(contentMode: .fit)
                .buttonify {
                    if self.txnType != type{
                        self.txnType = type
                    }
                }
                if idx < types.count - 1{
                    Spacer()
                }
            }
        }
    }
    
    var totalBoughtValue:Float{
        return self.txns.reduce(0, {$0 + $1.Total_Inclusive_Price * ($1.type == "sell" ? -1 : 1)})
    }
    
    var currentValue:Float{
        return self.totalCoins * self.currencyCurrentPrice
    }
    
    var profit:Float{
        return self.currentValue - self.totalBoughtValue
    }
    
    var totalCoins:Float{
        return self.txns.reduce(0, {$0 + $1.Asset_Quantity * ($1.type == "sell" ? -1 : 1)})
    }
    
    var totalFees:Float{
        return self.txns.reduce(0, {$0 + $1.Fee})
    }
    
    var AssetHeadKeys:[String]{
        return ["Value (bought)","Value (now)","Profit","Fees","Txns"]
    }
    
    var AssetHeadValue:[String:Float]{
        return ["Value (bought)":self.totalBoughtValue,"Value (now)":self.currentValue,"Profit":self.profit,"Fees":self.totalFees,"Txns": Float(self.txns.count)]
    }
    
}

struct CurrencyDetailTester:View{
    @StateObject var TAPI:CrybseTransactionAPI = .init()
    
    func onAppear(){
        self.TAPI.getTxns(uid: "jV217MeUYnSMyznDQMBgoNHfMvH2", currencies: ["XRP"])
    }
    
    var body: some View{
        Container(heading: "Transactions", width: totalWidth) { w in
            TransactionDetailsView(txns: self.TAPI.transactions,currency: "XRP",currencyCurrentPrice: 0.8,width: w)
        }.onAppear(perform: self.onAppear)
            .padding(.top,50)
    }
}

struct CurrencyAssetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CurrencyDetailTester()

        }
        .background(mainBGView)
        .edgesIgnoringSafeArea(.all)
    }
}
