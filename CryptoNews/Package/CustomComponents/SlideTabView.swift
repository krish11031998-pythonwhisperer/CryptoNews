//
//  SlideTabView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/10/2021.
//

import SwiftUI

public struct SlideTabView: View {
    var view:[AnyView]
    @State var page:Int = 0
    
    public init(view: @escaping () -> [AnyView]){
        self.view = view()
    }
    
    
    public var body: some View {
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
