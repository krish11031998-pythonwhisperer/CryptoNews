//
//  CrybsePostAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/01/2022.
//

import Foundation
import UIKit

struct CrybsePostPayload:Codable{
    var userImg:String?
    var userName:String?
    var userUid:String?
    var comments:String?
    var likes:String?
    var postMessage:String?
    var high:String?
    var low:String?
    var price:String?
    var view:String?
    var currency:String?
    var poll:[String:[String]]?
    var imageFile:Data?
}

class CrybsePostAPI:CrybseAPI{
    
    @Published var posts:[CrybPostData]? = nil
    static var shared: CrybsePostAPI = .init()
    
    var getReqeust:URLRequest?{
        var request = self.requestBuilder(path: "crybsePost/getPosts", queries: nil, headers: nil)
        request?.httpMethod = "GET"
        return request
    }
    
    var postRequest:URLRequest?{
        var request = self.requestBuilder(path: "crybsePost/uploadPost", queries: nil, headers: nil)
        request?.httpMethod = "POST"
        return request
    }

    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybsePostResponse.self, from: data)
            if let posts = res.data, res.success{
                setWithAnimation {
                    self.posts = posts 
                }
            }
            setWithAnimation {
                if self.loading{
                    self.loading.toggle()
                }
            }
            
        }catch{
            print("There was an error while trying to fetch the error! : ",error.localizedDescription)
        }
    }
    
    
    func parsePostFromData(data:Data) -> CrybPostData?{
        var post:CrybPostData? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseSinglePostResponse.self, from: data)
            if let safepost = res.data, res.success{
                post = safepost
            }
        }catch{
            print("There was an error while trying to fetch the error! : ",error.localizedDescription)
        }
        return post
    }
    
    
    func generateMultiPartFormRequest(url:URL?,post:CrybPostData,image:UIImage?) -> URLRequest?{
        guard let url = url else {return nil}
        let params = self.PostRequestBodyParams(post: post)
        var media:[Media]? = nil
        let multipartForm = MultipartFormDataRequest(url: url)
                
        if let safeImage = image,let imgMedia = Media.generateMediaDataFromImage(key: "imageFile", img: safeImage){
            if media == nil{
                media = [imgMedia]
            }else{
                media?.append(imgMedia)
            }
            print("(DEBUG) imgMedia has been generatedfromImage!")
        }
        
        if let safePoll = Media.generateMediaJSON(key: "poll", params: ["Ouestion":post.Poll.Question,"Options":post.Poll.Options]){
            if media == nil{
                media = [safePoll]
            }else{
                media?.append(safePoll)
            }
        }
        
        return multipartForm.asURLRequest(params: params, allMedia: media)
    }

    
    func parsePostForUpload(request: inout URLRequest,post:CrybPostData,image:UIImage?){
//        var payload = CrybsePostPayload(userImg: post.User.Img, userName: post.User.UserName, userUid: post.User.User_Uid, comments: "\(post.Comments)", likes: "\(post.Likes)", postMessage: post.PostMessage, high: "\(post.PricePrediction.High)", low: "\(post.PricePrediction.Low)", price: "\(post.PricePrediction.Price)", view: "\(post.Views)", currency: post.Coin)
//
//        if post.Poll.Question != "" && !post.Poll.Options.isEmpty{
//            payload.poll = ["question":post.Poll.Question,"options":post.Poll.Options]
//        }
//
//        if let imgData = image?.pngData(){
//            payload.imageFile = imgData
//        }
//
//        let encoder = JSONEncoder()
        do{
            let res = try JSONSerialization.data(withJSONObject: self.PostRequestBodyParams(post: post))
            print("(DEBUG) httpBody : ",res)
            request.httpBody = res
        }catch{
            print("(DEBUG Error) There was an error while trying to encode the the CrybsePostPayload : ",error.localizedDescription)
        }
    }
    
    func PostRequestBodyParams(post:CrybPostData) -> [String:Any]{
        var params:[String:Any] = ["userImg": post.User.Img,
                                   "userName": post.User.UserName,
                                   "userUid": post.User.User_Uid,
                                   "postMessage": post.PostMessage,
                                   "view": "\(post.Views)",
                                   "currency": "\(post.Coin)",
                                   "question": post.Poll.Question,
                                   "options":post.Poll.Options
        ]
        print("(DEBUG) Params : ",params)
        return params
    }
    
    func uploadPost(post:CrybPostData,image:UIImage?,completion:((Bool) -> Void)? = nil){
        if let safeRequest = self.generateMultiPartFormRequest(url: self.postRequest?.url, post: post, image: image){
            print("(DEBUG) Now Sending the request! : ",safeRequest.httpBody)
            self.PostData(request: safeRequest) { data in
                guard let safeData = data as? Data else {return}
                if let _ = self.parsePostFromData(data: safeData){
                    completion?(true)
                }else{
                    completion?(false)
                }
            }
            
        }
    }
    
    func getPosts(){
        guard let request = self.getReqeust else {return}
        self.getData(request: request)
    }

}
