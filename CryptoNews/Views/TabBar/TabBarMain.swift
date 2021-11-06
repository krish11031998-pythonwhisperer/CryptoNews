//
//  TabBarMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct TabBarMain: View {
    @EnvironmentObject var context:ContextData
    var tabs:[Tabs] = [.home,.search,.txn,.info,.profile]
    
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ForEach(self.tabs,id:\.rawValue) {tab in
                self.systemButtonView(tab: tab){
                    if self.context.tab != tab{
                        DispatchQueue.main.async {
                            withAnimation(.easeOut) {
                                self.context.tab = tab
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal,10)
        .padding(.vertical,10)
        .frame(alignment: .center)
        .background(BlurView(style: .regular))
        .clipContent(clipping: .roundClipping)
        .padding(.bottom,25)
        
        
    }
}


extension TabBarMain{
    @ViewBuilder func systemButtonView(tab:Tabs,action: @escaping () -> Void) -> some View{
        switch tab{
            case .feed,.reddit:
                SystemButton(haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), customIcon: tab.rawValue, bgcolor: .clear,action: action)
            default:
                SystemButton(b_name: tab.rawValue,haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), bgcolor: .clear,action: action)
        }
    }
}

struct TabBarMain_Previews: PreviewProvider {
    static var previews: some View {
        TabBarMain()
            .environmentObject(ContextData())
            .background(Color.black)
    }
}
