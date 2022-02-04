//
//  CrybPostGen.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/12/2021.
//

import SwiftUI

struct CrybPostGen: View {
    @EnvironmentObject var context:ContextData
    @State var text:String = ""
    @State var image:UIImage? = nil 
    @State var showImagePicker:Bool = false
    @StateObject var notification:NotificationData = .init()
    @State var textheight:CGFloat = .zero
    @State var keyboardHeight:CGFloat = .zero
    let staticText:String = "Enter the value !"
    
    init(){
        UITextView.appearance().backgroundColor = .clear
    }
    
    var textinTextEditor:String{
        return self.text.count == 0 ? staticText : self.text
    }
    
    var color:Color{
        return self.text.count == 0 ? .gray : .white
    }
    
    func uploadButton(){
        print("Update the button")
        guard let uid = self.context.user.user?.uid, let username = self.context.user.user?.userName else {return}
        var postdata:CrybPostData = .test
        postdata.User = .init(uid: uid, userName: username)
        postdata.PostMessage =  self.text
        CrybsePostAPI.shared.uploadPost(post: postdata, image: self.image) { status in
            var heading = ""
            var message = ""
            if status{
                heading = "Upload Successful"
                message = "Your CrybsePost was uploaded successfully !"
            }else{
                heading = "Upload Unsuccessful"
                message = "Your CrybsePost was not uploaded successfully !"
            }
            setWithAnimation {
                self.notification.updateNotification(heading: heading, buttonText: "Done", showNotification: true, innerText: message)
            }
        }
        
    }
    
    func sideButton(w:CGFloat) -> some View{
        return SystemButton(b_name: "plus", color: .white, haveBG: false, size: .init(width: 15, height: 15), bgcolor: .clear, alignment: .vertical, borderedBG: true) {
            if !self.showImagePicker{
                self.showImagePicker.toggle()
            }
        }.frame(width: w, alignment: .trailing)
        
    }
    
    @ViewBuilder func imageView(w:CGFloat) -> some View{
        let h = totalHeight * 0.175
        if let image = self.image{
            ImageView(img: image, width: w, height: h, contentMode: .fill, alignment: .center, clipping: .roundClipping)
        }else{
            Color.clear.frame(width: w, height: h, alignment: .center).clipContent(clipping: .roundClipping)
        }
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
        TextEditor(text: $text)
            .foregroundColor(Color.white)
            .font(.custom(TextStyle.normal.rawValue, size: 15, relativeTo: .body))
            .frame(maxHeight: totalHeight * 0.25, alignment: .leading)
            .padding()
            .background(BlurView.thinLightBlur.opacity(0.2).clipContent(clipping: .roundClipping))
    }
    
    var mainbody:some View{
        ZStack(alignment: .bottom) {
            Container(heading: "Add CrybPost", width: totalWidth,ignoreSides: false, verticalPadding: 50, onClose: self.onClose) { w in
                self.header
                
                StylizedTextEditor(limit:350,width: w)
                    .onPreferenceChange(StylizedTextEditorTextPreferenceKey.self) { newText in
                        if self.text != newText{
                            self.text = newText
                        }
                    }
                if self.keyboardHeight == .zero{
                    Spacer()
                    TabButton(width: w, height: 25, title: "Add Poll", textColor: .white) {
                        print("Click on Add Poll")
                    }
                    .padding(.bottom,5)
                    TabButton(width: w, height: 25, title: "Upload Post", textColor: .white, action: self.uploadButton)
                }else{
                    TabButton(width: w, height: 15, title: "Done Editting Post", textColor: .white, action: self.doneEditting)
                        .padding(.vertical,50)
                }
                
            }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
            if self.notification.showNotification{
                self.notification.generateView()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        
        
    }
    
    var body: some View {
    
    self.mainbody
        .frame(width: totalWidth, height: totalHeight, alignment: .bottomLeading)
            .padding(.top,self.keyboardHeight)
            .keyboardAdaptiveValue(keyboardHeight: $keyboardHeight)
//            .sheet(isPresented: $showImagePicker) {
//                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
//            }
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
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.userProfile?.img, width: totalWidth  * 0.1, height: totalWidth * 0.1, contentMode: .fill, alignment: .center, clipping: .circleClipping)
            MainText(content: self.userProfile?.userName ?? "CrybPostUser", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }
    }
    
}

struct CrybPostGen_Previews: PreviewProvider {
    
    static var context:ContextData = .init()
    
    static var previews: some View {
        CrybPostGen()
            .environmentObject(CrybPostGen_Previews.context)
            .background(mainBGView)
            .ignoresSafeArea()
    }
}
