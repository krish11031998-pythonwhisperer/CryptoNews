//
//  CurrencyAssetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct TransactionDetailsView: View {
    var transactions:[Transaction]
    var currencyCurrentPrice:Float
    @Binding var close:Bool
    var width:CGFloat
    
    init(txns:[Transaction],currencyCurrentPrice:Float,width:CGFloat = totalWidth,close:Binding<Bool>? = nil){
        self.transactions = txns
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
        }.padding(.bottom,20).frame(width: width, alignment: .topLeading)
    }
}

struct CurrencyDetailTester:View{
    @StateObject var TAPI:TransactionAPI = .init()
    
    var body: some View{
        Container(heading: "Transactions", width: totalWidth) { w in
            TransactionDetailsView(txns: self.TAPI.transactions.filter({$0.type == "buy" || $0.type == "sell"}),currencyCurrentPrice: 500,width: w)
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
