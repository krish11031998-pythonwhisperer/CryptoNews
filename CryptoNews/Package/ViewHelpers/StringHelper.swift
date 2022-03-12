import Foundation

public extension String{
    
    
    func toFloat() -> Float{
        return Float(self) ?? 0.0
    }
    
    func removeEndLine() -> String{
        let text = self
        return text.replacingOccurrences(of: "\n", with: "")
    }
    
    func stripSpaces() -> String{
        let text = self
        let finalText = text.components(separatedBy: " ").reduce("") { (res, x) -> String in
            return res == "" ? x : res + " " + x
        }
        return finalText
    }
    
    static func stringReducer(str:[String]) -> String{
        return str.reduce("") { (res, x) -> String in
            var res_str = ""
            if x == ""{
               return res
            }
            if res == ""{
                res_str = x
            }else{
                res_str = res + "\n\n" + x
            }
            return res_str
        }
    }

    func snakeCase() -> String{
        let text = self

        let finalText = text.components(separatedBy: " ").reduce("") { $0 == "" ? $1.lowercased() : $0 + "_" + $1.lowercased()}
        return finalText
    }
    
    func isImgURLStr() -> Bool{
        return self.contains(".jpg") || self.contains(".png")
    }
    
    func isURL() -> Bool{
        return self.contains("https://")
    }
    
    func containsURL() -> (body:String,url:[String]){
        let word = self
        var urls:[String] = []
        let fin_word = word.split(separator: " ").compactMap{ sequence -> String? in
            var res:String? = nil
            let word = String(sequence)
            if !word.isURL(){
                res = word
            }else{
                urls.append(word)
            }
            return res
        }.reduce("", {"\($0) \($1)"})
        return (body:fin_word,url:urls)
    }
}
