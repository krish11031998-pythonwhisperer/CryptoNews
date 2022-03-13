//
//  CustomTextField.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/12/2021.
//

import SwiftUI
import UIKit
import Combine


public class KeyboardHeightPreference:PreferenceKey{
    
    public static var defaultValue: CGFloat = .zero
    
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

public extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

public struct KeyboardAdaptive:ViewModifier{
    @State var keyboardHeight:CGFloat = 0
    @Binding var isKeyBoardOn:Bool
    
    public init(isKeyBoardOn:Binding<Bool>? = nil){
        self._isKeyBoardOn = isKeyBoardOn ?? .constant(false)
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight + 30)
            .onReceive(Publishers.keyboardHeight) { height in
                self.keyboardHeight = height
                if (height > 0 && !self.isKeyBoardOn) || (height == 0 && self.isKeyBoardOn){
                    self.isKeyBoardOn.toggle()
                }
            }
    }
}

public struct StylizedTextEditorTextPreferenceKey:PreferenceKey{
    public static var defaultValue : String = ""
    
    public static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

public struct TextLimiterStyle:Equatable{
    var color:Color
    var fontSize:CGFloat
    
    public init(color:Color,fontSize:CGFloat){
        self.color = color
        self.fontSize = fontSize
    }
    
    public static var light:TextLimiterStyle = .init(color: .white, fontSize: 15)
    public static var dark:TextLimiterStyle = .init(color: .black, fontSize: 15)
}

public class TextLimiter:ObservableObject{
    
    @Published var _text = "Enter Value"
    @Published var hadReachedLimit:Bool = false
    var limit:Int
    var style:TextLimiterStyle
    
    public init(placeHolder:String? = nil,limit:Int = 350,style:TextLimiterStyle = .light){
        self.limit = limit
        self.style = style
        if let safePlaceholder = placeHolder{
            self._text = safePlaceholder
        }
    }
        
    public var text:String {
        
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

public struct StylizedTextEditor:View{
    @StateObject var textObj:TextLimiter
    var placeHolder:String
    var includeIndicator:Bool
    var width:CGFloat
    var updateText:((String) -> Void)? = nil
    
    public init(placeHolder:String = "Enter Value",limit:Int = 350,includeIndicator:Bool = true,width:CGFloat = totalWidth - 20,style:TextLimiterStyle = .light,updateText:((String) -> Void)? = nil){
        self.placeHolder = placeHolder
        self._textObj = .init(wrappedValue: .init(placeHolder:placeHolder,limit: limit,style:style))
        self.includeIndicator = includeIndicator
        self.width = width
        self.updateText = updateText
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
    
    public var body: some View{
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
        .onChange(of: self.textObj.text) { newValue in
            if let safeUpdate = self.updateText{
                safeUpdate(newValue)
            }
        }
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

