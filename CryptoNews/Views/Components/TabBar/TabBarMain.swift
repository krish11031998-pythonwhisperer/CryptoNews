//
//  TabBarMain.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct TabBarMain: View {
    @EnvironmentObject var context:ContextData
    @Namespace var animation
    var tabs:[Tabs] = [.home,.search,.add,.info,.profile]
    
    var width:CGFloat{
        return totalWidth - 20
    }
    
    var tab_el_width:CGFloat{
        return (self.width - 30)/CGFloat(self.tabs.count) - 10
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            Container(width: totalWidth, ignoreSides: false) { w in
                HStack(alignment: .center, spacing: 20) {
                    ForEach(self.tabs,id:\.rawValue) {tab in
                        self.systemButtonView(tab: tab) {
                            self.onTapHandler(tab: tab)
                        }
                        if tab != .profile{
                            Spacer()
                        }
                    }
                }.frame(width: w, alignment: .center)
            }
            .padding(.vertical,25)
            .background(LinearGradient(colors: [Color.clear,Color.black.opacity(0.05),Color.black], startPoint: .top, endPoint: .bottom))
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
}


extension TabBarMain{
    
    var CircleBG:some View{
        Circle()
            .fill(Color.white)
            .matchedGeometryEffect(id: "background", in: animation)
            .frame(width: 40, height: 40, alignment: .center)
//            .animation(.easeInOut(duration: 0.2))
    }
    
    @ViewBuilder func systemButtonView(tab:Tabs,action: @escaping () -> Void) -> some View{
        let size:CGSize = .init(width: 20, height: 20)
        let isSelected = self.context.tab == tab && !self.context.addButtonPressed
        ZStack(alignment: .center) {
            if (tab == self.context.tab && !self.context.addButtonPressed) || (self.context.addButtonPressed && tab == .add){
                Circle()
                    .fill(Color.white.opacity(tab == .add ? 0.5 : 1))
                    .matchedGeometryEffect(id: "background", in: animation)
                    .frame(width: 40, height: 40, alignment: .center)
            }
            if tab == .add{
                ZStack(alignment: .center) {
                    SystemButton(b_name: tab.rawValue,color: isSelected ? .black : .white,haveBG: false,size: size,action: action)
                    if self.context.addButtonPressed {
                        SystemButton(b_name: "message", color: .black, haveBG: true, size: size,bgcolor: .white, action: {
                            self.onTapHandler(tab: .post)
                        })
                            .offset(x: -45, y: -45)
                            .transition(.move(edge: .bottom).combined(with: .move(edge: .trailing)))
                        SystemButton(b_name: "doc", color: .black, haveBG: true, size: size,bgcolor: .white, action: {
                            self.onTapHandler(tab: .txn)
                        })
                            .offset(x: 45, y: -45)
                            .transition(.move(edge: .bottom).combined(with: .move(edge: .leading)))
                    }
                }.animation(.easeInOut(duration: 0.1))
            }else{
                SystemButton(b_name: tab.rawValue,color: isSelected ? .black : .white,haveBG: false,size: size,action: action)
            }
        }.animation(.easeInOut(duration: 0.15))
    }
    
    func onTapHandler(tab:Tabs){
        if tab == .add{
            self.context.addButtonPressed.toggle()
            
        }else if self.context.tab != tab{
            self.context.tab = tab
            if self.context.addButtonPressed{
                self.context.addButtonPressed.toggle()
            }
        }else if self.context.tab == tab && self.context.addButtonPressed{
//            if self.context.addButtonPressed{
            self.context.addButtonPressed.toggle()
        }
        
//        if self.context.tab != tab && tab == .txn{
//            self.context.addTxn.toggle()
//        }
    }

}

struct TabBarMain_Previews: PreviewProvider {
    static var previews: some View {
        TabBarMain()
            .environmentObject(ContextData())
            .background(Color.AppBGColor.edgesIgnoringSafeArea(.top))
    }
}
