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
    
    
    init(previewText:String = "Enter Something here",textStyle:TextStyle = .normal,width:CGFloat = totalWidth,fontsize:CGFloat = 15, color:Color = .white.opacity(0.5)){
        self.previewText = previewText
        self.size = fontsize
        self.color = color
        self.textStyle = textStyle
        self.width = width
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

struct CustomTextFieldPreviews:PreviewProvider{
    
    static var previews: some View{
        ZStack(alignment: .top) {
            Color.mainBGColor
            CustomTextField()
                .background(Color.blue)
                .clipContent(clipping: .clipped)
                .padding(.top,50)
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .ignoresSafeArea()
        
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
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = true
        view.returnKeyType = .done
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
//            withAnimation(.easeInOut) {
//            self.customObserver.text = textView.text
//            if text_h <= totalHeight * 0.35{
//                self.customObserver.height =  text_h
//            }
            self.customObserver.height = text_h
            self.customObserver.text = textView.text
//            }
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
        }
    }
    
}

