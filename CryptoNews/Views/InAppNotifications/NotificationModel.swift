//
//  NotificationModel.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/11/2021.
//

import Foundation
import SwiftUI

class NotificationModel:ObservableObject{
    
    var header:String
    var message:String
    var actionlabel:String
    var onCloseAction:(() -> Void)?
    var action:(() -> Void)?
  
    
    init(header:String = "", message:String = "",actionLabel:String = "action",onCloseAction:(() -> Void)? = nil,action:(() -> Void)? = nil){
        self.header = header
        self.message = message
        self.onCloseAction = onCloseAction
        self.action = action
        self.actionlabel = actionLabel
    }
    
    @Published var viewNotification:Bool = false{
        willSet{
            if let closeAction = self.onCloseAction, !newValue{
                closeAction()
            }
        }
    }
    
    func updateNotification(heading:String,message:String,onClose:(() -> Void)? = nil){
        self.header = heading
        self.message = message
        self.onCloseAction = onClose
        withAnimation(.easeInOut(duration: 0.6)) {
            self.viewNotification = true
        }
    }
    
    func onCloseHandler(){
        if self.viewNotification{
            withAnimation(.easeInOut(duration: 0.6)) {
                self.viewNotification = false
            }
        }
    }
    
    func viewGenerator( w width:CGFloat) ->some View{
        ZStack(alignment: .center) {
            BlurView(style: .regular).frame(width: totalWidth, height: totalHeight, alignment: .center)
            Container(heading: self.header, width: width) { w in
                Group{
                    MainText(content: self.message, fontSize: 17, color: .white, fontWeight: .regular)
                        .lineLimit(4)
                    HStack(alignment: .center, spacing: 10) {
                        if let action = self.action{
                            MainText(content: self.actionlabel, fontSize: 13, color: .white, fontWeight: .regular, addBG: true)
                                .buttonify(handler: action)
                        }
                        MainText(content: "Ok", fontSize: 13, color: .white, fontWeight: .regular, addBG: true)
                            .buttonify(handler: self.onCloseHandler)
                    }.padding(.vertical).frame(width: w, alignment: .trailing)
                }
            }.basicCard(size: .init(width: width, height: .zero))
            
        }.frame(width: width, height: totalHeight, alignment: .center)
        
        
    }
    
}


struct NotificationViewTester:View{
    @StateObject var notification:NotificationModel = .init(header: "Testing", message: String.stringReducer(str: .init(repeating: "Testing Notification", count: 50)))
    
    var body: some View{
        ZStack(alignment: .center) {
            ProgressView()
            
            if self.notification.viewNotification{
                BlurView(style: .regular).frame(width: totalWidth, height: totalHeight, alignment: .center)
                self.notification.viewGenerator(w: totalWidth - 20)
                    .transition(.slideInOut)
                    .zIndex(3)
                    
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.mainBGColor)
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.notification.viewNotification = true
                }
            }
        }
        .onChange(of: self.notification.viewNotification) { newValue in
            if !newValue{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.notification.viewNotification = true
                    }
                }
            }
        }
    }
    
    
}

struct NotificationPreview:PreviewProvider{
    
    static var previews: some View {
        
        NotificationViewTester()
    
    }
    
    
}
