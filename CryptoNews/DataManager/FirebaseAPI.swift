//
//  FirebaseAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/10/2021.
//

import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


enum TransactionType:String{
    case buy = "buy"
    case sell = "sell"
    case send = "send"
    case receive = "receive"
    case none = "none"
}

struct Transaction:Codable{
    var time:String?
    var type:String?
    var asset:String?
    var asset_quantity:String?
    var asset_spot_price:String?
    var subtotal:String?
    var total_inclusive_price:String?
    var fee:String?
    var memo:String?
    
    var timeStamp:Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let time = time, let date = dateFormatter.date(from: time) else {return Date()}
        return date
    }
    
    static var currencyToSymConverter:[String:String]{
        return ["litecoin":"ltc","bitcoin":"btc","eth":"ethereum","xrp":"xrp"]
    }
    
    var symbol:String?{
        guard let asset = asset?.lowercased(), let sym = Transaction.currencyToSymConverter[asset] else {return nil}
        return sym
    }
    
    var _asset_quantity:Float{
        guard let val = self.asset_quantity, let val_fl = Float(val) else {return 0.0}
        return val_fl
    }
    
    var _asset_spot_price:Float{
        guard let val = self.asset_spot_price,let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
        return val_fl * 0.27
    }
    
    var _subtotal:Float{
        guard let val = self.subtotal, let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
        return val_fl * 0.27
    }
    
    var _total_inclusive_price:Float{
        guard let val = self.total_inclusive_price, let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
        return val_fl * 0.27
    }
    
    var _fee:Float{
        guard let val = self.fee,let val_str = val.split(separator: " ").first,let val_fl = Float(val_str) else {return 0.0}
        return val_fl * 0.27
    }
    
    
    var decoded:[String:Any]{
        return ["time":time,"type":type,"asset":asset,"asset_quantity":asset_quantity,"asset_spot_price":asset_spot_price,"subtotal":subtotal,"total_inclusive_price":total_inclusive_price,"fee":fee,"memo":memo]
    }
    
    static func parseFromQueryData(_ data : QueryDocumentSnapshot) -> Transaction?{
        var res:Transaction? = nil
        do{
            res = try data.data(as: Transaction.self)
        }catch{
            print("There was an error while decoding the data!",error.localizedDescription)
        }
        return res
    }
    
    func parseToPortfolioData() -> PortfolioData{
        return .init(type:self.type,crypto_coins: Double(self._asset_quantity), value_usd: self._asset_spot_price, fee: self._fee, totalfee: self._total_inclusive_price)
    }
    
}

class TransactionAPI:ObservableObject{
    
    @Published var transactions:[Transaction] = []
    
    var db:Firestore{
        return Firestore.firestore()
    }
    
    func FIRQueryListener(_ snapshot:QuerySnapshot?, _ err:Error?){
        guard let querySnapshot = snapshot else {return}
        
        DispatchQueue.main.async {
            self.transactions = querySnapshot.documents.compactMap({Transaction.parseFromQueryData($0)})
        }
        
    }
    
    func loadTransaction(){
//        db.collection("transactions").addSnapshotListener(self.FIRQueryListener(_:_:))
        db.collection("transactions").getDocuments(completion: self.FIRQueryListener(_:_:))
    }
    
    func uploadTransaction(txn:Transaction){
        db.collection("transactions").addDocument(data: txn.decoded) { err in
            if let err = err {
                print("There was an error while trying to add the txn to the database : ",err.localizedDescription)
            }
        }
    }
    
}
