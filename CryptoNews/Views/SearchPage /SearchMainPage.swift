//
//  SearchMainPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/11/2021.
//

import SwiftUI

struct SearchMainPage: View {
    @State var searchStr:String = ""
    @State var keyboardIsOn:Bool = false
    
    var SearchView:some View{
        HStack(alignment: .center, spacing: 10) {
            TextField("Search Coins & Exchanges", text: $searchStr)
                .padding(10)
                .background(BlurView(style: .regular))
                .clipContent(clipping: .squareClipping)
            
            MainText(content: "Cancel", fontSize: 10, color: .white, fontWeight: .semibold, style: .normal)
                .buttonify {
                    if self.keyboardIsOn{
                        self.keyboardIsOn.toggle()
                    }
                }
        }
        .padding(.horizontal,15)
        .frame(width: totalWidth, alignment: .leading)
        .padding(.bottom,10)
    }
    
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height: 50, alignment: .center)
                self.SearchView
                CryptoMarket(heading: "Biggest Gainer", srt: "pc",order: .desc,cardSize: CardSize.small)
                CryptoMarket(heading: "Biggest Losers", srt: "pc",order: .incr,cardSize: CardSize.small)
//            }.padding(.top,50)
            
        }
        
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        
        
        
    }
}

struct SearchMainPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchMainPage()
            
            
    }
}
