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
        if let uid = UserDefaults.standard.value(forKey: "eID") as? String,!self.loading{
            self.loading.toggle()
            self.context.user.signInUser_w_firUserUid(val: uid)
        }
    }
    
    var loadingView:some View{
        ZStack(alignment: .center) {
            Color.black.opacity(0.5)
            ProgressView()
        }.ignoresSafeArea()
    }
    
    
    var mainView:some View{
        Group{
            if self.context.loggedIn == .signedIn && !self.loading{
                CrybseView().environmentObject(self.context)
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
        }
        .onAppear(perform: self.onAppear)
        .onReceive(self.context.user.$user, perform: { user in
            guard let uid = user?.uid, let currencies = user?.watching else {return}
            CrybseAssetsAPI.shared.getAssets(symbols: currencies, uid: uid) { asset in
                setWithAnimation {
                    if let safeAsset = asset{
                        self.context.userAssets = safeAsset
                    }
                    self.loading.toggle()
                }
            }
        })
    }
    
    var body: some Scene {
        WindowGroup {
            self.mainView
        }
    }
}
