//
//  CurrencySymbolView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 20/10/2021.
//

import SwiftUI

enum CryptoIcon:String{
    case small = "32x32"
    case medium = "64x64"
    case large = "128x128"
    
}


struct CurrencySymbolView: View {
    
    var currency:String
    var size:CryptoIcon
    var width:CGFloat
    init(currency:String = "btc",size:CryptoIcon = .small,width:CGFloat){
        self.currency = currency
        self.size = size
        self.width = width
    }
    
    var img_url:String{
        let str = "https://api.coinicons.net/icon/\(currency)/\(size.rawValue)"
        return str
    }
    
    var body: some View {
        ImageView(url: self.img_url, width: self.width,height: self.width, contentMode: .fit, alignment: .center, clipping: .circleClipping)
    }
}

struct CurrencySymbolView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySymbolView(currency: "btc", size: .small, width: 100)
    }
}