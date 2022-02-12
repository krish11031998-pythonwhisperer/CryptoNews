//
//  HighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 19/01/2022.
//

import SwiftUI

struct HighlightPriceChangeView: View {
    @Binding var value:Float {
        willSet{
            self.updatePrice(newPrice: newValue)
        }
    }
    @State var color:Color = .black
    var baseColor:Color
    var fontSize:CGFloat
    
    init(value:Binding<Float>,baseColor:Color = .black,fontSize:CGFloat = 15){
        self._value = value
        self.baseColor = baseColor
        self.fontSize = fontSize
    }
    
    func updatePrice(newPrice:Float){
        setWithAnimation {
            if value < newPrice{
                self.color = .green
            }else if value > newPrice{
                self.color = .red
            }
        }
    }

    var body: some View {
        MainText(content: (self.value ?? 0).ToMoney(), fontSize: self.fontSize, color: self.color, fontWeight: .semibold)
            .onChange(of: self.color) { newColor in
                if newColor != .black{
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        withAnimation(.easeInOut){
                            self.color = .black
                        }
                    }
                }
            }
    }
}

//struct HighlightView_Previews: PreviewProvider {
//    static var previews: some View {
//        HighlightView()
//    }
//}
