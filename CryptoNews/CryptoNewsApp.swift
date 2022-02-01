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
    var timer = Timer.TimerPublisher(interval: 60, runLoop: .main, mode: .common).autoconnect()
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
    
    
    func fetchAssets(_ user:ProfileData?){
        guard let uid = user?.uid, let currencies = user?.watching else {return}
        CrybseAssetsAPI.shared.getAssets(symbols: currencies, uid: uid) { assets in
//            setWithAnimation {
                if let safeAssets = assets{
                    self.context.userAssets = safeAssets
                    print("(DEBUG) Tracked Assets : ",safeAssets.tracked)
                    print("(DEBUG) Watched Assets : ",safeAssets.watching)
                }
                if self.loading{
                    self.loading.toggle()
                }
//            }
        }
    }
    
    
    var mainView:some View{
        Group{
            if self.context.loggedIn == .signedIn && !self.loading{
                CrybseView()
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
        .onReceive(self.context.user.$user, perform: self.fetchAssets(_:))
    }
    
    var body: some Scene {
        WindowGroup {
            self.mainView
                .environmentObject(self.context)
        }
    }
}
