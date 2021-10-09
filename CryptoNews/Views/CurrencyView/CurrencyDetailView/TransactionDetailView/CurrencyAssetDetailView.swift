//
//  CurrencyAssetDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/10/2021.
//

import SwiftUI

struct TransactionDetailsView: View {
    var transactions:[Transaction]

    var body: some View {
        Container(heading: "Transactions", width: totalWidth, refresh: false) { w in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(self.transactions.enumerated()),id:\.offset) { _txn in
                        let txn = _txn.element
                        let idx = _txn.offset
                        SingleTransactionView(txn: txn,width: w)
                    }
                }.frame(width: w, alignment: .topLeading)
            }
        }.padding(.top,50)
    }
}

struct CurrencyDetailTester:View{
    @StateObject var TAPI:TransactionAPI = .init()
    
    var body: some View{
        TransactionDetailsView(transactions: self.TAPI.transactions)
            .onAppear(perform: self.TAPI.loadTransaction)
    }
}

struct CurrencyAssetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyDetailTester()
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}
