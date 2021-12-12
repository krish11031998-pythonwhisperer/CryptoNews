//
//  BottomSwipeCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/12/2021.
//

import SwiftUI

class NotificationData:ObservableObject{
    @Published var heading:String
    @Published var action:(() -> Void)? = nil
    @Published var buttonText:String
    @Published var innerText:String
    @Published var showNotification:Bool
    
    init(heading:String = "Test Notification",buttonText:String = "Done",showNotification:Bool = false,innerText:String = "This is the inner Text !",action:(() -> Void)? = nil){
        self.heading = heading
        self.buttonText = buttonText
        self.showNotification = showNotification
        self.innerText = innerText
        self.action = action
    }
    
    
    func updateNotification(heading:String = "Test Notification",buttonText:String = "Done",showNotification:Bool = false,innerText:String = "This is the inner Text !",action:(() -> Void)? = nil){
        self.heading = heading
        self.buttonText = buttonText
        self.showNotification = showNotification
        self.innerText = innerText
        self.action = action
    }
}



struct BottomSwipeCard<T:View>: View {
    
    var width:CGFloat
    var heading:String
    var innerView:T
    var buttonText:String
    var action:() -> Void
    init(width:CGFloat = totalWidth,heading:String,buttonText:String,@ViewBuilder innerView:() -> T,action: @escaping () -> Void){
        self.width = width
        self.heading = heading
        self.buttonText = buttonText
        self.innerView = innerView()
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: heading, fontSize: 25, color: .white, fontWeight: .semibold, style: .normal).padding(.bottom,20)
            innerView.padding(.vertical,5)
            Spacer()
            TabButton(width: self.width - 20, height: 50, title: self.buttonText, textColor: .white,action: action).padding(.bottom,15)
        }
        .padding(10)
        .padding(.vertical,15)
        .frame(width: self.width, alignment: .topLeading)
        .aspectRatio(contentMode: .fit)
        .background(BlurView(style: .systemThickMaterialDark))
        .clipContent(clipping: .roundClipping)
        .transition(.slideInOut)
        .zIndex(3)
    }
}

struct BottomSwipeCardTester:View{
//    @State var showCard:Bool = false
    @StateObject var context:ContextData = .init()
    
    func toggleShow(){
//        DispatchQueue.main.async{
        self.context.bottomSwipeNotification.showNotification.toggle()
//        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainBGView
            SystemButton(b_name: "plus") {
//                self.showCard.toggle()
                DispatchQueue.main.async {
                    self.context.bottomSwipeNotification.heading = "Test Notification"
                    self.context.bottomSwipeNotification.buttonText = "Done"
                    self.context.bottomSwipeNotification.showNotification = true
                    self.context.bottomSwipeNotification.innerText = "Testing the Notification Message!"
                }
            }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            if self.context.bottomSwipeNotification.showNotification{
                BottomSwipeCard(width: totalWidth, heading: self.context.bottomSwipeNotification.heading, buttonText: self.context.bottomSwipeNotification.buttonText) {
                    MainText(content: self.context.bottomSwipeNotification.innerText, fontSize: 15,fontWeight: .medium)
                } action: {
                    self.context.bottomSwipeNotification.action?() ?? toggleShow()
                }

                
            }
        }
        .animation(.easeInOut)
        .frame(width: totalWidth, height: totalHeight, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct BottomSwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        BottomSwipeCardTester()
    }
}
