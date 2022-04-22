//
//  CurrencySymbolView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 20/10/2021.
//

import SwiftUI

enum CryptoIcon:String{
//    case small = "32x32"
//    case medium = "64x64"
//    case large = "128x128"
    case small = "200"
    case medium = "400"
    case large = "600"
    
}


struct CurrencySymbolView: View {
    
    var url:String?
    var currency:String
    var size:CryptoIcon
    var width:CGFloat
    init(currency:String = "btc", url:String? = nil,size:CryptoIcon = .small,width:CGFloat){
        self.currency = currency
        self.url = url
        self.size = size
        self.width = width
    }
    
    var img_url:String{
        let str = "https://cryptoicons.org/api/icon/\(currency.lowercased())/\(self.size.rawValue)"
        return url ?? str
    }
    
    var body: some View {
        ImageView(url: self.url ?? self.img_url, width: self.width,height: self.width, contentMode: .fill, alignment: .center, clipping: .circleClipping)
    }
}

struct CurrencySymbolView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySymbolView(currency: "btc", size: .small, width: 100)
    }
}
