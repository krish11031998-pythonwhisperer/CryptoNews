//
//  LoginView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/11/2021.
//

import SwiftUI

struct FormTextField:TextFieldStyle{
    var color:Color
    var fontSize:CGFloat = 25
    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .truncationMode(.tail)
                .font(Font.custom(TextStyle.normal.rawValue, fixedSize: 12))
                .foregroundColor(color)
                .labelsHidden()
                .padding(.vertical,15)
                .padding(.horizontal,10)
                .background(BlurView(style: .regular))
                .clipContent(clipping: .squareClipping)
                
        }
}

extension View{
    func formFeild(heading:String,color:Color,fontSize:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: heading.capitalized, fontSize: 15, color: .white, fontWeight: .semibold)
            self.textFieldStyle(FormTextField(color: color,fontSize: fontSize))
        }
        
    }
}

class FormValues:ObservableObject,Loopable{
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var name:String = ""
    @Published var username:String = ""
    @Published var page:Int = 1
    @Published var confirmPwd:String = ""
    @Published var image:UIImage? = nil
    @Published var showImagePicker:Bool = false
    @Published var signIn:Bool = false
}


struct LoginView: View {
   
    @StateObject var formDetails:FormValues = .init()
    @EnvironmentObject var context:ContextData
    
    var formKeyValues:[String: Binding<String>] {
        return [
            "name":$formDetails.name,
            "username":$formDetails.username,
            "password":$formDetails.password,
            "email":$formDetails.email,
            "confirm password":$formDetails.confirmPwd,
            "image": .constant("")
        ]
    }
    
    var signUpformKeys:[String]{
        return ["email","password","confirm password"]
    }
    
    var signInformKeys:[String]{
        return ["email","password"]
    }
    
    var userformKeys:[String]{
        return ["image","name","username"]
    }
    
    func keyboardType(key:String) -> UIKeyboardType{
        var type:UIKeyboardType = .default
        switch(key){
            case "email","username":
                type = .emailAddress
            case "password","confirm password":
                type = .emailAddress
            default:
                type = .emailAddress
        }
        return type
    }
    
    @ViewBuilder func textField(key:String) -> some View{
        if let val = self.formKeyValues[key]{
            if key.contains("password"){
                SecureField("", text: val)
                    .formFeild(heading:key,color: .white, fontSize: 15)
                    .keyboardType(self.keyboardType(key: key))
            }else{
                TextField("", text: val)
                    .formFeild(heading:key,color: .white, fontSize: 15)
                    .keyboardType(self.keyboardType(key: key))
            }
        }else{
            Color.clear.frame(width: 0, height: 0, alignment: .center)
        }
        
    }
    
    func signUpUser(){
        if self.formDetails.password != self.formDetails.confirmPwd {
            self.formDetails.password = ""
            self.formDetails.email = ""
            self.formDetails.confirmPwd = ""
        }
        print("Sign Up Pressed")
        AuthManager.shared.signUpUser(email: self.formDetails.email, password: self.formDetails.password) { user in
            print("user : ",user)
            self.formDetails.page += 1
            self.context.user.fir_user = user
        }
    }
    
    
    func profileImageView() -> some View{
        ImageView(img: self.formDetails.image, width: totalWidth * 0.3, height: totalWidth * 0.3, contentMode: .fill, alignment: .center, clipping: .circleClipping)
    }
    
    func signUpPageGen(heading:String,fields:[String],button:String = "Sign Up",actionHandler: @escaping () -> Void, anotherButton: (() -> AnyView)? = nil) -> some View{
        VStack(alignment: .center, spacing: 15) {
            MainText(content: heading, fontSize: 35, color: .white, fontWeight: .semibold)
                
            ForEach(fields, id:\.self){ key in
                if let val = self.formKeyValues[key]{
                    if key.contains("password"){
                        SecureField("", text: val)
                            .formFeild(heading:key,color: .white, fontSize: 15)
                            .keyboardType(self.keyboardType(key: key))
                    }else if key == "image"{
                        self.profileImageView()
                            .buttonify {
                                withAnimation(.easeInOut) {
                                    self.formDetails.showImagePicker.toggle()
                                }
                            }
                    }else{
                        TextField("", text: val)
                            .formFeild(heading:key,color: .white, fontSize: 15)
                            .keyboardType(self.keyboardType(key: key))
                    }
                }else{
                    Color.red.frame(width: 10, height: 10, alignment: .center)
                }
            }
            TabButton(width: totalWidth - 30, height: 50, title: button, textColor: .white,action: actionHandler)
            anotherButton?()
        }
        .padding()
        .frame(width: totalWidth,height: totalHeight, alignment: .center)
        .keyboardAdaptive(isKeyBoardOn: .constant(false))
    }
    
    func loggedIn(){
        if self.context.loggedIn != .signedIn{
            self.context.loggedIn = .signedIn
        }
    }
    
    func createUserInDB() {
        if self.formDetails.name != "" && self.formDetails.username != ""{
            self.context.user.user?.name = self.formDetails.name
            self.context.user.user?.userName = self.formDetails.username
            if let image = self.formDetails.image, let imgData = image.png(){
                ProfileAPI.shared.uploadImageToStorage(data: imgData, folder: "images") { url in
                    self.context.user.user?.img = url
                    self.context.user.createUser()
                }
            }else{
                self.context.user.createUser()
            }
            
        }
    }
    
    func signInUser(){
        AuthManager.shared.signInUser(email: self.formDetails.email, password: self.formDetails.password) { user in
            UserDefaults.standard.setValue(user.uid, forKey: "eID")
            UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
            DispatchQueue.main.async {
                if self.context.user.fir_user?.uid != user.uid{
                    self.context.user.fir_user = user
                }
                
            }
            
        }
    }
    
    @ViewBuilder var nextPageAfterSignUp:some View{
        let heading = self.formDetails.signIn ? "Sign In" : "Update Personal Info"
        let fields = self.formDetails.signIn  ? signInformKeys : userformKeys
        let button = self.formDetails.signIn ? "Sign In" : "Update"
        let handler = self.formDetails.signIn ? self.signInUser : self.createUserInDB
        self.signUpPageGen(heading: heading,fields: fields, button: button,actionHandler: handler)
    }
    
    
    var mainBody:some View{
        TabView(selection: $formDetails.page) {
            self.signUpPageGen(heading: "Sign Up", fields: self.signUpformKeys,actionHandler: self.signUpUser,anotherButton: {
                AnyView(TabButton(width: totalWidth - 30, height: 50, title: "Already a User? Sign In", textColor: .white,action: {
                    withAnimation(.easeInOut) {
                        if !self.formDetails.signIn{
                            self.formDetails.signIn.toggle()
                        }
                        if self.formDetails.page != 2{
                            self.formDetails.page = 2
                        }
                        print("formDetails : ",self.formDetails.signIn,self.formDetails.page)
                    }
                }))
            })
            .tag(1)
            
            self.nextPageAfterSignUp
                .tag(2)
            
            
        }.tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onChange(of: self.context.user.user?.userName, perform: { newValue in
            if  newValue != nil && self.formDetails.signIn && self.context.loggedIn != .signedIn{
                DispatchQueue.main.async {
                    self.context.loggedIn = .signedIn
                }
            }
        })
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black
            Color.mainBGColor.opacity(0.3)
            self.mainBody
        }
        
        .sheet(isPresented: $formDetails.showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $formDetails.image)
        }
        
        .animation(.easeInOut)

    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .edgesIgnoringSafeArea(.all)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
}
