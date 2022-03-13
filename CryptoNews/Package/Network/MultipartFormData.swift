//
//  MultipartFormData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/01/2022.
//

import Foundation
import UIKit

public typealias Params = [String:Any]


public struct Media{
    var name:String
    var data:Data
    var mimeType:String
    var filename:String?
    
    
    public static func generateMediaJSON(key:String,params:[String:Any]) -> Media?{
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
    
    public static func generateMediaDataFromImage(key:String,img:UIImage) -> Media?{
        guard let data = img.jpegData(compressionQuality: 0.5) else {return nil}
        return Media(name: key, data: data, mimeType: "image/jpg",filename:"\(arc4random()).jpg")
    }
}


public extension URLSession {
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}

public struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    let url: URL

    public init(url: URL) {
        self.url = url
    }
    
    public func writeFormData(bodyData:inout Data,params:Params? = nil){
        let lineBreak = "\r\n"
        guard let safeParams = params else {return}
        for (key,value) in safeParams{
            bodyData.append("--\(boundary + lineBreak)")
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak+lineBreak)")
            if let StrValue = value as? String{
                bodyData.append("\(StrValue + lineBreak)")
            }else if let StrArrValue = value as? Array<String> {
                for value in StrArrValue{
                    bodyData.append("--\(boundary + lineBreak)")
                    bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak+lineBreak)")
                    bodyData.append("\(value + lineBreak)")
                }
            }else if let safeData = value as? Data{
                bodyData.append(contentsOf: safeData)
            }
            
        }
    }

    public func generateRequestDataBoundary(params:Params? = nil,allmedia:[Media]? = nil) -> Data{
        var bodyData = Data()
        let lineBreak = "\r\n"
        
        if let safeParams = params{
            self.writeFormData(bodyData: &bodyData, params: params)
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
        print("(DEBUG) bodyData : ",bodyData)
        
        return bodyData
    }
    
    public func asURLRequest(params:Params? = nil,allMedia:[Media]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = self.generateRequestDataBoundary(params: params, allmedia: allMedia)
    
        return request
    }
}

public extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
