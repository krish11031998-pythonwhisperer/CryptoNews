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
import FirebaseStorage

protocol CompletionHandler{
    func parseData(data:[QueryDocumentSnapshot]) -> Void
}

class FIRStorageManager:NSObject{
    
    static var shared:FIRStorageManager = FIRStorageManager()
    func uploadTask(data:Data,path:String,handler:@escaping (String) -> Void){
        let storageRef = Storage.storage().reference()
        var Ref = storageRef.child(path)
        var _url:String = ""
        let task = Ref.putData(data, metadata: nil) { (meta, err) in
            guard let metadata = meta else{
                handler(_url)
                return
            }
            
            let size = metadata.size
            Ref.downloadURL { (url, err) in
                guard let url = url else{
                    if err != nil{
                        print("There was an error ! : \(err!.localizedDescription)")
                    }
                    handler(_url)
                    return
                }
                _url = url.absoluteString
                print("_url : \(_url)")
                handler(_url)
            }
        }
    }
}

class FirebaseAPI:ObservableObject,CompletionHandler{
    
    var collection:String
    @Published var loading:Bool = false
    
    init(collection:String){
        self.collection = collection
    }
    
    var db:Firestore{
        return Firestore.firestore()
    }
    
    func parseDocuments(_ data : QuerySnapshot?, _ err : Error?){
        guard let documents = data?.documents else {
            var errStr : String = "There was an error while trying to parse the data"
            if let err = err?.localizedDescription{
                errStr += ": \(err)"
            }
            return
        }
        self.parseData(data: documents)
    }
    
    func loadData(val:String){
        self.db.collection(collection)
            .whereField("uid", isEqualTo: val)
            .getDocuments(completion: self.parseDocuments(_:_:))
    }
    
    func loadData(val:String,completion: @escaping (QuerySnapshot?,Error?) -> Void){
        self.db
            .collection(collection)
            .whereField("uid", isEqualTo: val)
            .getDocuments(completion: completion)
    }
    
    func loadData(){
        db.collection(collection).getDocuments(completion: self.parseDocuments(_:_:))
    }
    
    func parseData(data: [QueryDocumentSnapshot]) {
        print("Here is the data : ",data);
    }
        
    func uploadTransaction(data:[String:Any],completion:((Error?) -> Void)? = nil){
        db.collection(collection).addDocument(data: data) { err in
            if let err = err {
                print("There was an error while trying to add the txn to the database : ",err.localizedDescription)
                
            }
            DispatchQueue.main.async {
                completion?(err)
            }
            
        }
    }
    
    func uploadImageToStorage(data:Data,folder:String,completion:@escaping (String?) -> Void){
        let folderPath = "\(folder)/\(NSUUID().uuidString).jpg"
        FIRStorageManager.shared.uploadTask(data: data, path: folderPath) { (url) in
            completion(url)
        }
    }
}

