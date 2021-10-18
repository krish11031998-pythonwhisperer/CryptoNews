//
//  CurrencyAssetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct TransactionDetailsView: View {
    var transactions:[Transaction]
    var currency:String
    var currencyCurrentPrice:Float
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
    
    func onClose(){
        withAnimation(.easeInOut) {
            self.close.toggle()
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(Array(self.transactions.enumerated()),id:\.offset) { _txn in
                let txn = _txn.element
                SingleTransactionView(txn: txn, currentPrice: self.currencyCurrentPrice,width: width)
            }
            TabButton(width: width, height: 50, title: "Add Txn", textColor: .white) {
                withAnimation(.easeInOut) {
                    if !self.context.addTxn{
                        self.context.addTxn.toggle()
                        self.context.selectedSymbol = self.currency
                    }
                }
            }
        }.padding(.bottom,20).frame(width: width, alignment: .topLeading)
    }
}

struct CurrencyDetailTester:View{
    @StateObject var TAPI:TransactionAPI = .init()
    
    var body: some View{
        Container(heading: "Transactions", width: totalWidth) { w in
            TransactionDetailsView(txns: self.TAPI.transactions.filter({$0.type == "buy" || $0.type == "sell"}),currency: "LTC",currencyCurrentPrice: 500,width: w)
        }.onAppear(perform: self.TAPI.loadTransaction)
    }
}

struct CurrencyAssetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyDetailTester()
            .background(Color.mainBGColor)
            .edgesIgnoringSafeArea(.all)
    }
}
