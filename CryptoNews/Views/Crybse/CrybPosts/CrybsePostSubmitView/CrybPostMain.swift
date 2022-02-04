//
//  CrybPostMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/01/2022.
//

import SwiftUI

struct CrybPostMain: View {
    
    @EnvironmentObject var context:ContextData
    
    
    var postPage:AnyView{
        let view = CrybPostGen()
            .environmentObject(self.context)
        return AnyView(view)
//            .onPreferenceChange(<#T##key: PreferenceKey.Protocol##PreferenceKey.Protocol#>, perform: <#T##(Equatable) -> Void#>)
    }
    
    func viewGen() -> [AnyView]{
        return [AnyView(CrybPostGen().environmentObject(self.context)),AnyView(AddPollPage())]
    }
    
    var body: some View {
        SlideTabView(view: self.viewGen)
    }
}

struct CrybPostMain_Previews: PreviewProvider {
    
    @StateObject static var context:ContextData = .init()
    
    static var previews: some View {
        CrybPostMain()
            .environmentObject(CrybPostMain_Previews.context)
    }
}
