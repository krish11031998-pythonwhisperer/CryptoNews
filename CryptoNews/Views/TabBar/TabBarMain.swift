//
//  TabBarMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct TabBarMain: View {
    @EnvironmentObject var context:ContextData
    var tabs:[Tabs] = [.home,.feed,.txn,.news]
    
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 25) {
            ForEach(self.tabs,id:\.rawValue) {tab in
                self.systemButtonView(tab: tab){
                    if self.context.tab != tab{
                        DispatchQueue.main.async {
                            self.context.tab = tab
                        }
                    }
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.vertical,10)
        .padding(.bottom,25)
        .frame(width: totalWidth - 20, alignment: .leading)
    }
}


extension TabBarMain{
    @ViewBuilder func systemButtonView(tab:Tabs,action: @escaping () -> Void) -> some View{
        switch tab{
            case .feed,.reddit:
                SystemButton(haveBG: self.context.tab != tab,size: .init(width: 30, height: 30), customIcon: tab.rawValue, bgcolor: .clear,action: action)
            default:
                SystemButton(b_name: tab.rawValue,haveBG: self.context.tab != tab,size: .init(width: 30, height: 30), bgcolor: .clear,action: action)
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
