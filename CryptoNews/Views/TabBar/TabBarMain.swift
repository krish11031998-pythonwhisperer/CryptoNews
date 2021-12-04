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
    
    var width:CGFloat{
        return totalWidth - 20
    }
    
    var tab_el_width:CGFloat{
        return (self.width - 30)/CGFloat(self.tabs.count) - 10
    }
    
    var body: some View {
        Container(width: totalWidth, ignoreSides: false) { w in
            HStack(alignment: .center, spacing: 20) {
                ForEach(self.tabs,id:\.rawValue) {tab in
                    self.systemButtonView(tab: tab) {
                        self.onTapHandler(tab: tab)
                    }
                }
            }.frame(width: w, alignment: .center)
        }.padding(.vertical,25)
            .padding(.bottom,25)
            .background(LinearGradient(colors: [Color.clear,Color.black], startPoint: .top, endPoint: .bottom))
        
        
    }
    
}


extension TabBarMain{
    @ViewBuilder func systemButtonView(tab:Tabs,action: @escaping () -> Void) -> some View{
        switch tab{
            case .feed,.reddit:
                SystemButton(haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), customIcon: tab.rawValue, bgcolor: .clear,action: action)
            default:
            SystemButton(b_name: tab.rawValue,haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), bgcolor: .clear,action: action).frame(width: self.tab_el_width, alignment: .center)
        }
    }
    
    func onTapHandler(tab:Tabs){
        if self.context.tab != tab && tab != .txn{
            DispatchQueue.main.async {
                withAnimation(.easeOut) {
                    self.context.tab = tab
                }
            }
        }else if self.context.tab != tab && tab == .txn{
            DispatchQueue.main.async {
                withAnimation(.easeOut) {
                    self.context.addTxn.toggle()
                }
            }
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
