//
//  Transaction.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/11/2021.
//

import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI


enum TransactionType:String{
    case buy = "buy"
    case sell = "sell"
    case send = "send"
    case receive = "receive"
    case none = "none"
}

struct Transaction:Codable{
    var time:String
    var type:String
    var asset:String
    var asset_quantity:Float
    var asset_spot_price:Float
    var subtotal:Float
    var total_inclusive_price:Float
    var fee:Float
    var memo:String
    var uid:String
    
    static var empty:Transaction = .init(time: "", type: "", asset: "", asset_quantity: 0, asset_spot_price: 0, subtotal: 0, total_inclusive_price: 0, fee: 0, memo: "",uid: "")
    
    var timeStamp:Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: time) else {return Date()}
        return date
    }
    
    static var currencyToSymConverter:[String:String]{
        return ["litecoin":"ltc","bitcoin":"btc","eth":"ethereum","xrp":"xrp"]
    }
    
    static var symToCurrencyConverter:[String:String]{
//        Transaction.currencyToSymConverter.map
        return ["ltc" : "litecoin","btc":"bitcoin","ethereum":"eth","xrp":"xrp"]
    }
    
    var symbol:String?{
        get{
            let asset = asset.lowercased()
            return asset
        }
        set{
            self.asset = newValue ?? ""
        }
        
    }
    
    var decoded:[String:Any]{
        return ["time":time,"type":type,"asset":asset,"asset_quantity":asset_quantity,"asset_spot_price":asset_spot_price,"subtotal":subtotal,"total_inclusive_price":total_inclusive_price,"fee":fee,"memo":memo,"uid":uid]
    }
    
    static func parseFromQueryData(_ data : QueryDocumentSnapshot) -> Transaction?{
        var res:Transaction? = nil
        do{
            print(data.data())
            res = try data.data(as: Transaction.self)
        }catch{
            print("There was an error while decoding the data!",error.localizedDescription)
        }
        return res
    }
    
    func parseToPortfolioData() -> PortfolioData{
        var value_now = self.asset_quantity * self.asset_spot_price
        return .init(type:self.type,crypto_coins: Double(self.asset_quantity), value_usd: value_now,profit: value_now - self.subtotal, fee: self.fee, totalfee: self.total_inclusive_price)
    }
    
}


class TransactionAPI:FirebaseAPI{
    @Published var transactions:[Transaction] = []
    
    init(){
        super.init(collection: "transactions")
    }
        
    static var shared:TransactionAPI = .init()

    override func parseData(data: [QueryDocumentSnapshot]) {
        DispatchQueue.main.async {
            self.transactions = data.compactMap({Transaction.parseFromQueryData($0)})
            if !self.loading{
                self.loading.toggle()
            }
        }
    }
        
    func uploadTransaction(txn:Transaction,completion:((Error?) -> Void)? = nil){
        self.uploadTransaction(data: txn.decoded, completion: completion)
    }
    
    func loadTransactions(uuid:String,currency:String){
        DispatchQueue.main.async {
            if !self.loading{
                self.loading.toggle()
            }
            
        }
        if !self.transactions.isEmpty{
            self.transactions.filter({$0.asset == currency})
        }else{
            self.db
                .collection("transactions")
                .whereField("uid", isEqualTo: uuid)
                .whereField("asset", isEqualTo: currency)
                .getDocuments { qss, err in
                    if let docs = qss?.documents{
                        self.parseData(data: docs)
                    }else if let err = err{
                        print("Error : ",err.localizedDescription)
                    }
                }
        }
        
       
    }
    
    func loadTransaction(uuid:String? = nil){
        DispatchQueue.main.async {
            if !self.loading{
                self.loading.toggle()
            }
        }
        if let uuid = uuid{
            self.loadData(val: uuid)
        }else{
            self.loadData()
        }
    }
}
