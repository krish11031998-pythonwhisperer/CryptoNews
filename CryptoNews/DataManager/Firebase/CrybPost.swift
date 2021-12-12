//
//  CrybPostAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/12/2021.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

class CrybPostAPI:FirebaseAPI,ObservableObject{
    @Published var posts:[CrybPostData] = []
    
    init(){
        super.init(collection: "cryb_posts")
    }
        
    static var shared:CrybPostAPI = .init()

    override func parseData(data: [QueryDocumentSnapshot]) {
        DispatchQueue.main.async {
            self.posts = data.compactMap({CrybPostData.parseFromQueryData($0)})
        }
    }
        
    func uploadTransaction(post:CrybPostData,image:UIImage? = nil,completion:((Error?) -> Void)? = nil){
        if let image = image?.png(){
            self.uploadImageToStorage(data: image, folder: "images") { _img_url in
                var postwImg:CrybPostData = post
                if let img_url = _img_url{
                    postwImg.PostImage = img_url
                }
                self.uploadTransaction(data: postwImg.decoded, completion: completion)
            }
        }else{
            self.uploadTransaction(data: post.decoded, completion: completion)
        }
    }
    
    func loadPosts(uuid:String,currency:String){
        self.db
            .collection("cryb_posts")
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
    
    func loadPost(uuid:String? = nil){
        if let uuid = uuid{
            self.loadData(val: uuid)
        }else{
            self.loadData()
        }
    }
}
