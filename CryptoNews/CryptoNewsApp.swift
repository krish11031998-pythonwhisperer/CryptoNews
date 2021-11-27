//
//  CryptoNewsApp.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct CryptoNewsApp: App {
    @StateObject var context: ContextData = .init()
    @State var loading:Bool = false
    init(){
        FirebaseApp.configure()
    }
    
    func onAppear(){
        if let uid = UserDefaults.standard.value(forKey: "eID") as? String{
            self.loading.toggle()
            self.context.user.signInUser_w_firUserUid(val: uid)
        }
    }
    
    var loadingView:some View{
        ZStack(alignment: .center) {
            Color.black.opacity(0.5)
            ProgressView()
        }
    }
    
    func onChangeUser(_ uid:String?){
        if let _ = uid, self.loading{
            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }
    
    var mainView:some View{
        Group{
            if self.context.loggedIn == .signedIn{
                ContentView().environmentObject(self.context)
            }else{
                if self.loading{
                    LoginView()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: totalWidth, height: totalHeight, alignment: .center)
                        .environmentObject(self.context)
                        .overlay(self.loadingView)
                }else{
                    LoginView()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: totalWidth, height: totalHeight, alignment: .center)
                        .environmentObject(self.context)
                }
            }
        }.onAppear(perform: self.onAppear)
        .onChange(of: self.context.user.user?.uid,perform: self.onChangeUser(_:))
    }
    
    var body: some Scene {
        WindowGroup {
            self.mainView
//            NotificationViewTester()
//            NewsSectionMain()
        }
    }
}
