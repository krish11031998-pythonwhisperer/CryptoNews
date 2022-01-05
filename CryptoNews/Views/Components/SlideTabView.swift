//
//  SlideTabView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/10/2021.
//

import SwiftUI

struct SlideTabView: View {
    @EnvironmentObject var context:ContextData
    var view:[AnyView]
    @State var page:Int = 0
    init(view: @escaping () -> [AnyView]){
        self.view = view()
    }
    
    
    var body: some View {
        TabView(selection: $page){
            ForEach(Array(self.view.enumerated()),id:\.offset) { _view in
                let idx = _view.offset
                let view = _view.element
                view
                    .edgesIgnoringSafeArea(.all)
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: totalWidth, alignment: .top)
        
        
            
    }
}

struct SlideTabView_Previews: PreviewProvider {
    @StateObject static var context = ContextData()
    static var previews: some View {
        SlideTabView(view: {
//            return [AnyView(Color.red.edgesIgnoringSafeArea(.all)),AnyView(Color.blue.edgesIgnoringSafeArea(.all))]
            return [AnyView(CurrencyFeedMainPage(type: .news).environmentObject(SlideTabView_Previews.context)),AnyView(CurrencyFeedMainPage(type: .feed).environmentObject(SlideTabView_Previews.context))]
        })
            .edgesIgnoringSafeArea(.all)
    }
}
