//
//  RefreshTimerView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 16/02/2022.
//

import SwiftUI
import Combine

public struct RefreshTimerView: View {
    @State var timeCounter:Int = 0
    @Binding var refresh:Bool
    var timeLimit:Int
    let timer:Publishers.Autoconnect<Timer.TimerPublisher>
    
    public init(timeLimit:Int = 30,refresh:Binding<Bool> = .constant(false)){
        self.timeLimit = timeLimit
        self.timer  = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self._refresh = refresh
    }
    
    var refreshMeter:some View{
        let percent = (1 - Float(self.timeCounter)/Float(timeLimit))
        let color = percent > 0.65 ? Color.green : percent <= 0.65 && percent >= 0.35 ? Color.orange : Color.red
        return VStack(alignment: .center, spacing: 5) {
            MainText(content: "Refresh", fontSize: 15, color: .white, fontWeight: .semibold)
                .buttonify {
                    if !self.refresh{
                        self.refresh.toggle()
                    }
                }
            if self.refresh{
                ProgressView()
            }else{
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .background(BlurView.thinDarkBlur)
                        .frame(width: 50, height: 2, alignment: .center)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color)
                        .frame(width: 50 * CGFloat(percent), height: 2, alignment: .center)
                }
            }
        }
    }
    
    func OnReceiveTimer(_ time:Date){
        if self.timeCounter < timeLimit{
            withAnimation(.easeInOut){
                self.timeCounter += 1
            }
        }else if !self.refresh{
            self.refresh = true
        }
    }
    
    public var body: some View {
        self.refreshMeter
            .onReceive(self.timer, perform: self.OnReceiveTimer)
            .onDisappear {self.timer.upstream.connect().cancel()}
            .onChange(of: self.refresh) { newValue in
                if !newValue && self.timeCounter != 0{
                    self.timeCounter = 0
                }
            }
    }
}

struct RefreshTimerView_Previews: PreviewProvider {
    
    @State static var refresh:Bool = false
    
    static var previews: some View {
        RefreshTimerView(refresh:RefreshTimerView_Previews.$refresh)
            .padding()
            .background(Color.mainBGColor)
            
    }
}
