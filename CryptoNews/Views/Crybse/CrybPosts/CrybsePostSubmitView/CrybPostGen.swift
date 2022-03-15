//
//  CrybPostGen.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/12/2021.
//

import SwiftUI

struct CrybPostGen: View {
    @EnvironmentObject var context:ContextData
    @EnvironmentObject var postState:CrybsePostState
    @State var keyboardHeight:CGFloat = .zero
    let staticText:String = "Enter the value !"

    init(){
        UITextView.appearance().backgroundColor = .clear
    }
    
    var text:String{
        get{
            return self.postState.text
        }
        
        set{
            self.postState.text = newValue
        }
    }
    
    var textinTextEditor:String{
        return self.text.count == 0 ? staticText : self.text
    }
    
    var color:Color{
        return self.text.count == 0 ? .gray : .white
    }
    
    func uploadButton(){
        self.postState.addPost.toggle()
    }
    
    var containerHeight:CGFloat{
        return totalHeight - self.keyboardHeight
    }
    
    func doneEditting(){
        setWithAnimation {
            if self.keyboardHeight != .zero{
                 UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    @ViewBuilder var textField:some View{
        MainText(content: "Post about what you think....", fontSize: 15, color: .white.opacity(0.75), fontWeight: .semibold)
        TextEditor(text: self.$postState.text)
            .foregroundColor(Color.white)
            .font(.custom(TextStyle.normal.rawValue, size: 15, relativeTo: .body))
            .frame(maxHeight: totalHeight * 0.25, alignment: .leading)
            .padding()
            .background(BlurView.thinLightBlur.opacity(0.2).clipContent(clipping: .roundClipping))
    }
    
    var mainbody:some View{
        ZStack(alignment: .bottom) {
            Container(heading: "Add CrybPost", width: totalWidth,ignoreSides: false, verticalPadding: 50, onClose: self.onClose,spacing: 10) { w in
                self.header
                
                StylizedTextEditor(limit:350,width: w)
                    .onPreferenceChange(StylizedTextEditorTextPreferenceKey.self) { newText in
                        if self.text != newText{
                            self.postState.text = newText
                        }
                    }
                if self.keyboardHeight == .zero{
                    Spacer()
                    Container(width:w,spacing: 15){ w in
                        TabButton(width: w, title: "Add Poll", textColor: .white) {
                            if self.postState.page != 2{
                                self.postState.page = 2
                            }
                        }
                        TabButton(width: w, title: "Upload Post", textColor: .white, action: self.uploadButton)
                    }
                    
                }else{
                    TabButton(width: w, title: "Done Editting Post", textColor: .white, action: self.doneEditting)
//                        .padding(.vertical,50)
                }
                
            }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        
        
    }
    
    var body: some View {
    
    self.mainbody
        .frame(width: totalWidth, height: totalHeight, alignment: .bottomLeading)
            .padding(.top,self.keyboardHeight)
            .keyboardAdaptiveValue(keyboardHeight: $keyboardHeight)
        .onAppear {
            if self.context.showTab{
                self.context.showTab.toggle()
            }
        }
        .onDisappear {
            if !self.context.showTab{
                self.context.showTab.toggle()
            }
        }


        
    }
}

extension CrybPostGen{

    var userProfile:ProfileData?{
        return self.context.user.user
    }

    func onClose(){
        if self.context.addPost{
            self.context.addPost.toggle()
        }
        
        if self.context.tab == .post{
            self.context.tab = self.context.prev_tab
        }
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.userProfile?.img, width: totalWidth  * 0.1, height: totalWidth * 0.1, contentMode: .fill, alignment: .center, clipping: .circleClipping)
            MainText(content: self.userProfile?.userName ?? "CrybPostUser", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }
    }
    
}

//struct CrybPostGen_Previews: PreviewProvider {
//    
//    static var context:ContextData = .init()
//    @State static var text:String = ""
//    static var previews: some View {
//        CrybPostGen(text: .constant(""))
//            .environmentObject(CrybPostGen_Previews.context)
//            .background(mainBGView)
//            .ignoresSafeArea()
//    }
//}
