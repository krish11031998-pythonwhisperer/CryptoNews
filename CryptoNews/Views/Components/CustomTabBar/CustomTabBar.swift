////
////  CustomTabBar.swift
////  CryptoNews
////
////  Created by Krishna Venkatramani on 05/01/2022.
////
//
//import SwiftUI
//
//struct CustomTabBarView<SelectionValue:TabBarItem,Content:View>:View{
//    @EnvironmentObject var context:ContextData
//    var content:Content
//    
//    init (@ViewBuilder content: () -> Content){
//        self.content = content()
//    }
//    
//    
//    var body: some View{
//        Container { w in
//            ZST
//        }
//    }
//}
//
//extension CustomTabBarView{
//    
////    var width:CGFloat{
////        return totalWidth - 20
////    }
////
////    var tab_el_width:CGFloat{
////        return (self.width - 30)/CGFloat(self.tabs.count) - 10
////    }
//    
//    @ViewBuilder func systemButtonView(tab:Tabs,action: @escaping () -> Void) -> some View{
//        switch tab{
//            case .feed,.reddit:
//                SystemButton(haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), customIcon: tab.rawValue, bgcolor: .clear,action: action)
//            default:
//            SystemButton(b_name: tab.rawValue,haveBG: self.context.tab != tab,size: .init(width: 20, height: 20), bgcolor: .clear,action: action).frame(alignment: .center).frame(maxWidth:.infinity)
//        }
//    }
//    
//    func onTapHandler(tab:Tabs){
//        if self.context.tab != tab && tab != .txn{
//            self.context.tab = tab
//        }else if self.context.tab != tab && tab == .txn{
//            self.context.addTxn.toggle()
//        }
//
//    }
//}
//
////struct CustomTabBarView: View {
////    var body: some View {
////        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
////    }
////}
////
////struct CustomTabBar_Previews: PreviewProvider {
////    static var previews: some View {
////        CustomTabBarView()
////    }
////}
