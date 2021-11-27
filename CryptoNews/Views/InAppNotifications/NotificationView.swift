//
//  NotificationView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/11/2021.
//

import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var context:ContextData
    
    
    var width:CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            BlurView(style: .regular).frame(width: totalWidth, height: totalHeight, alignment: .center)
            Container(heading: self.context.notification.header, width: width) { w in
                Group{
                    MainText(content: self.context.notification.message, fontSize: 17, color: .white, fontWeight: .regular)
                        .lineLimit(4)
                    HStack(alignment: .center, spacing: 10) {
                        if let action = self.context.notification.action{
                            MainText(content: self.context.notification.actionlabel, fontSize: 13, color: .white, fontWeight: .regular, addBG: true)
                                .buttonify(handler: action)
                        }
                        MainText(content: "Ok", fontSize: 13, color: .white, fontWeight: .regular, addBG: true)
                            .buttonify(handler: self.context.notification.onCloseHandler)
                    }.padding(.vertical).frame(width: w, alignment: .trailing)
                }
            }.basicCard(size: .init(width: width, height: .zero))
            
        }.frame(width: width, height: totalHeight, alignment: .center)
        
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(width:totalWidth - 20)
    }
}
