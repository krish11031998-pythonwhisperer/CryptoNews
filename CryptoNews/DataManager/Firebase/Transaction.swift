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
    var asset_quantity:String
    var asset_spot_price:String
    var subtotal:String
    var total_inclusive_price:String
    var fee:String
    var memo:String
    var uid:String
    
    static var empty:Transaction = .init(time: "", type: "", asset: "", asset_quantity: "", asset_spot_price: "", subtotal: "", total_inclusive_price: "", fee: "", memo: "",uid: "")
    
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
//            guard let sym = Transaction.currencyToSymConverter[asset] else {return nil}
//            return sym
            return asset
        }
        set{
//            guard let sym = newValue?.lowercased(), let currency = Transaction.symToCurrencyConverter[sym] else {return}
            self.asset = newValue ?? ""
        }
        
    }
    
    var _asset_quantity:Float{
        get{
            let val = self.asset_quantity
            guard let val_fl = Float(val) else {return 0.0}
            return val_fl
        }
        
        set{
            self.asset_quantity = String(newValue)
        }
    }
    
    var _asset_spot_price:Float{
        get{
            let val = self.asset_spot_price
            guard let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
            return val_fl
        }
        set{
            self.asset_spot_price = String(newValue)
        }
        
    }
    
    var _subtotal:Float{
        get{
            let val = self.subtotal
            guard  let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
            return val_fl
        }
        
        set{
            self.subtotal = String(newValue)
        }
        
    }
    
    var _total_inclusive_price:Float{
        get{
            let val = self.total_inclusive_price
            guard let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
            return val_fl
        }
        set{
            self.total_inclusive_price = String(newValue)
        }
        
    }
    
    var _fee:Float{
        get{
            let val = self.fee
            guard let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
            return val_fl
        }
        
        set{
            self.fee = String(newValue)
        }
    }
    
    
    var decoded:[String:Any]{
        return ["time":time,"type":type,"asset":asset,"asset_quantity":asset_quantity,"asset_spot_price":asset_spot_price,"subtotal":subtotal,"total_inclusive_price":total_inclusive_price,"fee":fee,"memo":memo]
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
        return .init(type:self.type,crypto_coins: Double(self._asset_quantity), value_usd: self._asset_spot_price,current_val: self._asset_spot_price, fee: self._fee, totalfee: self._total_inclusive_price)
    }
    
}


class TransactionAPI:FirebaseAPI,ObservableObject{
    @Published var transactions:[Transaction] = []
    init(){
        super.init(collection: "transactions")
    }
        
    static var shared:TransactionAPI = .init()

    override func parseData(data: [QueryDocumentSnapshot]) {
        DispatchQueue.main.async {
            self.transactions = data.compactMap({Transaction.parseFromQueryData($0)})
        }
    }
        
    func uploadTransaction(txn:Transaction,completion:((Error?) -> Void)? = nil){
        self.uploadTransaction(data: txn.decoded, completion: completion)
    }
    
    func loadTransactions(uuid:String,currency:String){
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
    
    func loadTransaction(uuid:String? = nil){
        if let uuid = uuid{
            self.loadData(val: uuid)
        }else{
            self.loadData()
        }
    }
}
