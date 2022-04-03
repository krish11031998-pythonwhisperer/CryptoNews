//
//  TransactionData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/01/2022.
//

import Foundation
import Firebase
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
    var asset_quantity:Float?
    var asset_spot_price:Float?
    var subtotal:Float?
    var total_inclusive_price:Float?
    var fee:Float?
    var memo:String?
    var uid:String?
    
    var Time:String{
        return self.time ?? ""
    }
    
    var TxnType:String{
        return self.type ?? ""
    }
    
    var Asset:String{
        return self.asset ?? ""
    }
    
    var Asset_Quantity:Float{
        return self.asset_quantity ?? 0.0
    }
    
    var Asset_Spot_Price:Float{
        return self.asset_spot_price ?? 0.0
    }
    
    var Subtotal:Float{
        return self.subtotal ?? 0.0
    }
    
    var Total_Inclusive_Price:Float{
        return self.total_inclusive_price ?? 0.0
    }
    
    var Fee:Float{
        return self.fee ?? 0.0
    }
    
    var Memo:String{
        return self.memo ?? ""
    }
    
    var Uid:String{
        return self.uid ?? ""
    }
    
    static var empty:Transaction = .init(time: "", type: "", asset: "", asset_quantity: 0, asset_spot_price: 0, subtotal: 0, total_inclusive_price: 0, fee: 0, memo: "",uid: "")
    
    var timeStamp:Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: Time) else {return Date()}
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
            let asset = Asset.lowercased()
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
        var value_now = self.Asset_Quantity * self.Asset_Spot_Price
        return .init(type:self.type,crypto_coins: Double(self.Asset_Quantity), value_usd: value_now,profit: value_now - self.Subtotal, fee: self.Fee,totalfee: self.Total_Inclusive_Price, currentPrice: 0)
    }
    
}

struct TransactionResponse:Codable{
    var data:[Transaction]?
    var success:Bool
}


class TxnFormDetails:ObservableObject{
    @Published var time:String = ""
    @Published var type:TransactionType  = .none
    @Published var asset:String  = "0"
    @Published var asset_quantity:String  = "0"
    @Published var asset_spot_price:String = "0"
    @Published var fee:String = "0"
    @Published var uid:String  = ""
    @Published var added_Success:Bool = false
    @Published var date:Date = Date()
    
    init(asset:String? = nil,assetPrice:String? = nil){
        self.asset_spot_price = assetPrice ?? ""
        self.asset = asset ?? ""
    }
    
    static var empty:TxnFormDetails = .init()
    
    func updateTxnDetails(_ value:String,_ type:ModalType){
        if type == .fee{
            self.fee = value
        }else if type == .spot_price{
            self.asset_spot_price = value
        }else{
            self.asset_quantity = value
        }
    }
    
    func reset(){
        self.time = ""
        self.type = .none
        self.asset = ""
        self.asset_spot_price = "0"
        self.asset_quantity = ""
        self.asset = ""
        self.fee = "0"
        self.uid = ""
        self.added_Success = false
        self.date = Date()
        
    }
}
