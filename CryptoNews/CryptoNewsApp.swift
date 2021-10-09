//
//  CryptoNewsApp.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI
import FirebaseCore
@main
struct CryptoNewsApp: App {
    @StateObject var context:ContextData = .init()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(self.context)
        }
    }
}
