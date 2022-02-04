//
//  CustomTextField.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/12/2021.
//

import SwiftUI
import UIKit

struct StylizedTextEditorTextPreferenceKey:PreferenceKey{
    static var defaultValue : String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct TextLimiterStyle:Equatable{
    var color:Color
    var fontSize:CGFloat
    
    static var light:TextLimiterStyle = .init(color: .white, fontSize: 15)
    static var dark:TextLimiterStyle = .init(color: .black, fontSize: 15)
}

class TextLimiter:ObservableObject{
    
    @Published var _text = "Enter Value"
    @Published var hadReachedLimit:Bool = false
    var limit:Int
    var style:TextLimiterStyle
    init(placeHolder:String? = nil,limit:Int = 350,style:TextLimiterStyle = .light){
        self.limit = limit
        self.style = style
        if let safePlaceholder = placeHolder{
            self._text = safePlaceholder
        }
    }
        
    var text:String {
        
        get{
            return self._text
        }
        
        set {
            if !self.hadReachedLimit{
                if newValue.count > self.limit{
                    self.hadReachedLimit = true
                }else{
                    self._text = newValue
                }
            }else if self.hadReachedLimit && newValue.count < self.limit{
                if newValue.contains("\n"){
                    self._text = newValue.replacingOccurrences(of: "\n", with: "")
                    return
                }
                self._text = newValue
            }
        }
    }
    
    var font:Font{
        if let uiFont = UIFont(name: TextStyle.normal.rawValue, size: self.style.fontSize){
            return Font(uiFont)
        }else{
            return .body
        }
    }
    
    func resetPlaceHolder(){
        if self._text  != ""{
            self._text = ""
        }
    }
    
    var fontColor:Color{
        if self.text == "Enter Value"{
            return self.style.color.opacity(0.75)
        }else{
            return self.style.color
        }
    }
    
    var count:Int{
        if self.text == "Enter Value"{
            return self.limit
        }else{
            return self.limit - self.text.count
        }
        
    }
    
    var percent:Float{
        return Float(self.count)/Float(self.limit)
    }
    
    var countColor:Color{
        if percent >= 0.75{
            return .green
        }else if percent < 0.75 && percent >= 0.5{
            return .yellow
        }else if percent < 0.5 && percent >= 0{
            return .pink
        }
        
        return .clear
    }
 
    
    
}

struct StylizedTextEditor:View{
    @StateObject var textObj:TextLimiter
    var placeHolder:String
    var includeIndicator:Bool
    var width:CGFloat
    init(placeHolder:String = "Enter Value",limit:Int = 350,includeIndicator:Bool = true,width:CGFloat = totalWidth - 20,style:TextLimiterStyle = .light){
        self.placeHolder = placeHolder
        self._textObj = .init(wrappedValue: .init(placeHolder:placeHolder,limit: limit,style:style))
        self.includeIndicator = includeIndicator
        self.width = width
        UITextView.appearance().backgroundColor = .clear
    }
    
    func RemovePlaceHolderText(){
        if self.textObj.text == self.placeHolder{
            self.textObj.resetPlaceHolder()
        }
    }
    
    func textEditorView(w:CGFloat) -> some View{
        TextEditor(text: self.$textObj.text)
            .onTapGesture(perform: self.RemovePlaceHolderText)
            .font(self.textObj.font)
            .foregroundColor(self.textObj.fontColor)
            .frame(width: w, alignment: .topLeading)
            .frame(maxHeight: totalHeight * 0.35, alignment: .center)
            .aspectRatio(contentMode: .fit)

            .keyboardType(.twitter)
            .padding(.top,-7.5)
        
    }
    
    func countBar(w:CGFloat) -> some View{
        ZStack(alignment: .leading) {
            BlurView.thinLightBlur.frame(width: w, height: 4, alignment: .leading)
            self.textObj.countColor.frame(width: w * CGFloat(1 - self.textObj.percent), height: 4, alignment: .leading)
        }.frame(width: w, height : 4, alignment: .leading)
            .clipContent(clipping: .roundClipping)
    }
    
    var body: some View{
        Container(width:self.width,horizontalPadding: 10,verticalPadding: 5) { w in
            self.textEditorView(w: w)
            if self.includeIndicator{
                self.countBar(w: w)
                MainText(content: "\(self.textObj.count)", fontSize: 15, color: self.textObj.countColor, fontWeight: .bold)
                    .frame(width: w, alignment: .leading)
            }
        }
        .frame(width: self.width)
        .clipContent(clipping: .roundClipping)
        .preference(key: StylizedTextEditorTextPreferenceKey.self, value: self.textObj.text)
    }
}

struct CustomTextFieldPreviews:PreviewProvider{
    @State static var text:String = "Enter something here !"
    static var previews: some View{
        ZStack(alignment: .top) {
            Color.mainBGColor.ignoresSafeArea()
            StylizedTextEditor().padding(.top,100)
        }
        
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
}

