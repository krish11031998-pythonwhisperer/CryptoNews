//
//  CustomTextField.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 10/12/2021.
//

import SwiftUI
import UIKit

// MARK: CustomFontPreference

class CustomFontPreference:PreferenceKey{
    
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

// MARK: CustomFont

struct CustomFont{
    var previewText:String
    var size:CGFloat
    var color:Color
    var textStyle:TextStyle
    var width:CGFloat
    var maxHeight:CGFloat
    
    
    init(previewText:String = "Enter Something here",textStyle:TextStyle = .normal,width:CGFloat = totalWidth,maxHeight:CGFloat = totalHeight * 0.3,fontsize:CGFloat = 15, color:Color = .white.opacity(0.5)){
        self.previewText = previewText
        self.size = fontsize
        self.color = color
        self.textStyle = textStyle
        self.width = width
        self.maxHeight = maxHeight
    }
    
    var fontName:String{
        return self.textStyle.rawValue
    }
}

// MARK: CustomTextField

struct CustomTextField:View{
    @StateObject var customFontObserver:CustomTextFieldObserver = .init()
    var customFont:CustomFont
    var width:CGFloat = .init()
    
    
    init(customFont:CustomFont? = nil,width:CGFloat = totalWidth - 20){
        self.customFont = customFont ?? .init(width:width)
        self.width = width
    }
    
    var body: some View{
        CustomTextFieldView(customFont: self.customFont)
            .padding(.horizontal,10)
            .frame(width: self.width, height: self.customFontObserver.height, alignment: .center)
            .clipContent(clipping: .clipped)
            .environmentObject(self.customFontObserver)
            .preference(key: CustomFontPreference.self, value: self.customFontObserver.text)
    }
}


struct StylizedTextEditorTextPreferenceKey:PreferenceKey{
    static var defaultValue : String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

class TextLimiter:ObservableObject{
    
    @Published var _text = "Enter Value"
    @Published var hadReachedLimit:Bool = false
    var limit:Int

    init(limit:Int = 350){
        self.limit = limit
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
                if newValue.contains("Enter Value"){
                    _ = newValue.replacingOccurrences(of: "Enter Value", with: "")
                }
                self._text = newValue
            }
        }
    }
    
    var font:Font{
        if let uiFont = UIFont(name: TextStyle.normal.rawValue, size: 15){
            return Font(uiFont)
        }else{
            return .body
        }
    }
    
    var fontColor:Color{
        if self.text == "Enter Value"{
            return .white.opacity(0.75)
        }else{
            return .white
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

struct StlyizedTextEditor:View{
    @StateObject var textObj:TextLimiter
    var width:CGFloat
    init(limit:Int = 350,width:CGFloat = totalWidth - 20){
        self._textObj = .init(wrappedValue: .init(limit: limit))
        self.width = width
        UITextView.appearance().backgroundColor = .clear
    }
    

    
    func textEditorView(w:CGFloat) -> some View{
        TextEditor(text: self.$textObj.text)
            .font(self.textObj.font)
            .foregroundColor(self.textObj.fontColor)
            .frame(width: w, alignment: .topLeading)
            .frame(maxHeight: totalHeight * 0.35, alignment: .center)
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                if self.textObj.text == "Enter Value"{
                    self.textObj.text = ""
                }
            }
        
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
            self.countBar(w: w)
            MainText(content: "\(self.textObj.count)", fontSize: 15, color: self.textObj.countColor, fontWeight: .bold)
                .frame(width: w, alignment: .leading)
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
            StlyizedTextEditor().padding(.top,100)
        }
        
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        
        
    }
    
}

// MARK: CustomTextFieldObserver

class CustomTextFieldObserver:ObservableObject{
    @Published private var _height:CGFloat = 50
    @Published private var _text:String = ""
    
    var height:CGFloat{
        get{
            return self._height
        }
        
        set{
            if self._height <= totalHeight * 0.35{
                self._height = newValue
            }
        }
    }
    
    
    var text:String{
        get{
            return self._text
        }
        
        set{
            if newValue.count < 350{
                self._text = newValue
            }
        }
    }
    
}

// MARK: CustomTextFieldView

struct CustomTextFieldView:UIViewRepresentable{
    
    var customFont:CustomFont = .init()
    @EnvironmentObject var customObserver:CustomTextFieldObserver
    
    init(customFont:CustomFont){
        self.customFont = customFont
    }
    
    var minH:CGFloat{
        self.customObserver.height < 100 ? 100 : self.customObserver.height
    }
    
    var size:CGSize{
        .init(width: self.customFont.width - 20, height: minH - 10)
    }
    
    var font:UIFont{
        if let font = UIFont(name: self.customFont.fontName, size: self.customFont.size){
            return font
        }else{
            return .systemFont(ofSize: self.customFont.size)
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<CustomTextFieldView>) -> UITextView {
        let view = UITextView(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        view.delegate = context.coordinator
        view.font = font
        view.text = self.customFont.previewText
        view.textColor = UIColor(self.customFont.color)
        view.backgroundColor = .clear
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
    
    func updateUIView(_ textView: UITextView, context: UIViewRepresentableContext<CustomTextFieldView>) {
        var text_h:CGFloat = self.customObserver.height
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if text_h != newSize.height {
            text_h = newSize.height
        }
        
        DispatchQueue.main.async {
            if text_h < self.customFont.maxHeight{
                self.customObserver.height = text_h
            }
            self.customObserver.text = textView.text
        }
        
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator:NSObject,UITextViewDelegate{
        
        var parent:CustomTextFieldView
        
        init(parent:CustomTextFieldView){
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == self.parent.customFont.previewText{
                textView.text = ""
                textView.textColor = .white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == ""{
                textView.text = self.parent.customFont.previewText
                textView.textColor = .gray
            }
            
            if textView.text.contains("\n"){
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                DispatchQueue.main.async {
                    textView.resignFirstResponder()
                }
            }
            
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Always dismiss KB upon textField 'Return'
            return true
        }
    }
    
}

