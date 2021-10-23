//
//  FeedPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct FeedPage: View {
    @Binding var symbol:String
    
    init(symbol:Binding<String>){
        self._symbol = symbol
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FeedPage_Previews: PreviewProvider {
    static var previews: some View {
        FeedPage(symbol: .constant("LTC"))
    }
}
