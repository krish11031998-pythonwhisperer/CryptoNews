//
//  DynamicHeightContainer.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 04/02/2022.
//

import SwiftUI

struct DynamicheightContainerPreference:PreferenceKey{
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DynamicHeightContainer<T:View>: View {
    @State var height:CGFloat = .zero
    var innerView:T
    
    init(@ViewBuilder innerView: @escaping () -> T){
        self.innerView = innerView()
    }
    
    var body: some View {
        GeometryReader{g -> AnyView in
            
            let height = g.size.height
            
            setWithAnimation {
                if height != self.height{
                    self.height = height
                }
            }
            
            
            return AnyView(innerView)
        }.preference(key: DynamicheightContainerPreference.self, value: self.height)
    }
}

