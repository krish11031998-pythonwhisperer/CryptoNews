//
//  AddTransaction.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/01/2022.
//

import Foundation

class CrybseTransactionPostRepsonse:Codable{
    var data:Transaction?
    var success:Bool
    var err: String?
    
    static func parseTransactonResponseFromData(data:Data) -> CrybseTransactionPostRepsonse?{
        var res: CrybseTransactionPostRepsonse? = nil
        let decoder = JSONDecoder()
        do{
            res = try decoder.decode(CrybseTransactionPostRepsonse.self, from: data)
        }catch{
            print("(ERROR) Error while trying to parse the CrybseTransactionResponse : ",error.localizedDescription)
        }
        return res
    }
}

class CrybseTransactionAPI:CrybseAPI{
    @Published var transactions:[Transaction] = []
    
    var baseTransactionUrl:URLComponents{
        var uC = self.baseComponent
        uC.path = "/transactions"
        return uC
    }
    
    static var shared : CrybseTransactionAPI = .init()
    
    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(TransactionResponse.self, from: data)
            if let txns = res.data, res.success{
                setWithAnimation {
                    self.transactions = txns
                    if self.loading{
                        self.loading.toggle()
                    }
                }
            }
        }catch{
            print("(DEBUG) There was an error while trying to parse the txns ! : ",error.localizedDescription)
        }
    }
    
    
    func URLBuilder(path:String,queries:[String:String]) -> URL?{
        var uC = self.baseTransactionUrl
        uC.path += path
        for (key,value) in queries{
            if uC.queryItems == nil{
                uC.queryItems = [URLQueryItem(name: key, value: value)]
            }else{
                uC.queryItems?.append(.init(name: key, value: value))
            }
        }
        return uC.url
        
    }
    
    func getTxns(uid:String,currencies:[String]){
        guard let url = self.URLBuilder(path: "/getTxns", queries: ["uid":uid,"currency":currencies.joined(separator: ",")]) else {return}
        self.getData(_url: url)
    }
    
    func postTxn(txn:TxnFormDetails,completion:((Any) -> Void)? = nil){
        guard let url = self.URLBuilder(path: "/postTxns", queries: ["time":txn.date.stringDate(),"type":txn.type.rawValue,"asset":txn.asset,"asset_quantity":txn.asset_quantity,"asset_spot_price":txn.asset_spot_price,"fee":txn.fee,"uid":txn.uid]) else {return}
        self.PostData(url: url,parseFunc: { data in
            if let resp = CrybseTransactionPostRepsonse.parseTransactonResponseFromData(data: data){
                completion?(resp)
            }
        })
    }
}
