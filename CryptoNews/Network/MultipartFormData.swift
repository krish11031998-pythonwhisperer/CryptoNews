//
//  MultipartFormData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/01/2022.
//

import Foundation
import UIKit

typealias Params = [String:Any]

extension Params{
    
}

struct Media{
    var name:String
    var data:Data
    var mimeType:String
    var filename:String?
    
    
    static func generateMediaJSON(key:String,params:[String:Any]) -> Media?{
        var data:Data? = nil
        do{
            data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }catch{
            print("The error while trying to serialize the Data : ",error.localizedDescription)
        }
        
        if let safeData = data {
            return Media(name: key, data: safeData, mimeType: "application/json")
        }else{
            return nil
        }
        

    }
    
    static func generateMediaDataFromImage(key:String,img:UIImage) -> Media?{
        guard let data = img.jpegData(compressionQuality: 0.5) else {return nil}
        return Media(name: key, data: data, mimeType: "image/jpg",filename:"\(arc4random()).jpg")
    }
}


extension URLSession {
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func generateRequestDataBoundary(params:Params? = nil,allmedia:[Media]? = nil) -> Data{
        var bodyData = Data()
        let lineBreak = "\r\n"
        if let safeParams = params{
            for (key,value) in safeParams{
                bodyData.append("--\(boundary + lineBreak)")
                bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak+lineBreak)")
                if let StrValue = value as? String{
                    bodyData.append("\(StrValue + lineBreak)")
                }else if let safeData = value as? Data{
                    bodyData.append(contentsOf: safeData)
                }
                
            }
        }
        
        
        if let allSafeMedia = allmedia{
            for media in allSafeMedia{
                bodyData.append("--\(boundary + lineBreak)")
                bodyData.append("Content-Disposition: form-data; name=\"\(media.name)\";")
                if let safeFilename = media.filename{
                    bodyData.append("filename=\"\(safeFilename)\"")
                }
                bodyData.append("\(lineBreak+lineBreak)")
                bodyData.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)")
                bodyData.append(media.data)
                bodyData.append(lineBreak)
            }
        }
        
        bodyData.append("--\(boundary)--\(lineBreak)")
        
        return bodyData
    }
    
    func asURLRequest(params:Params? = nil,allMedia:[Media]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = self.generateRequestDataBoundary(params: params, allmedia: allMedia)
    
        return request
    }
}

//extension NSMutableData {
//  func append(_ string: String) {
//    if let data = string.data(using: .utf8) {
//      self.append(data)
//    }
//  }
//}

extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
