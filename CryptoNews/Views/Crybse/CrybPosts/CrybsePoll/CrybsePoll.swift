//
//  CrybsePoll.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/02/2022.
//

import SwiftUI

struct CrybsePoll: View {
    @StateObject var poll:CrybsePollData
    var width:CGFloat = .zero
    var height:CGFloat?
    var alertEventChange:Bool = false
    @State var change:String = CardFanSwipe.none.rawValue
    @State var selectedOption:String = ""
    
    init(poll:CrybsePollData,width:CGFloat,height:CGFloat? = nil,alertEventChange:Bool = false){
        self.width = width
        self._poll = .init(wrappedValue: poll)
        self.height = height
        self.alertEventChange = alertEventChange
    }
    
    
    var headerView:some View{
        MainText(content: self.poll.Question, fontSize: 20, color: .white, fontWeight: .medium)
    }
    
    @ViewBuilder func backgroundSelector(option:String,width:CGFloat) -> some View{
        let isSelected = option == self.selectedOption
        if self.selectedOption != ""{
            if isSelected{
                Color.mainBGColor
                    .frame(width: width * 0.65)
                    .clipContent(clipping: .roundClipping)
            }else{
                Color.gray
                    .opacity(0.5)
                    .frame(width: width * 0.35)
                    .clipContent(clipping: .roundClipping)
            }
        }
    }
    
    func optionBuilder(option:String,width:CGFloat) -> some View{
        let isSelected = option == self.selectedOption
        var optionRatio = self.poll.OptionRatio(option: option)
        let isSelectedBackground = Color.mainBGColor.frame(width:  isSelected ? width * CGFloat(optionRatio) : 0).opacity(isSelected ? 1 : 0).clipContent(clipping: .clipped).anyViewWrapper()
        return
        
        MainText(content: option, fontSize: 13, color: .white, fontWeight: .regular)
            .makeAdjacentView(orientation: .horizontal, alignment: .center, position: .right, spacing: 0, otherView: {
                if self.selectedOption != "" {
                    Spacer()
                    MainText(content: optionRatio.ToDecimals(), fontSize: 13, color: .white, fontWeight: .medium, padding: 0)
                }
            })
        .padding()
        .frame(width: width, alignment: .leading)
        .background(isSelectedBackground,alignment: .leading)
        .buttonclickedhighlight(selected: isSelected)
        .clipContent(clipping: .roundClipping)
        .buttonify {
            if self.selectedOption != option{
                setWithAnimation {
                    if self.selectedOption != ""{
                        self.poll.UpdateOptionCount(option: self.selectedOption, count: -1)
                    }
                    self.selectedOption = option
                    self.poll.UpdateOptionCount(option: option)
                }
            }
        }
    }
    
    @ViewBuilder var mainBody:some View{
        Container(heading: self.poll.Question, headingColor: .white, headingDivider: false, headingSize: 20, width: self.width,ignoreSides: false, verticalPadding: 20) { w in
            ForEach(self.poll.Options , id: \.self) { option in
                self.optionBuilder(option: option, width: w)
            }
        }
        .onChange(of: self.selectedOption, perform: { _ in
            if self.alertEventChange && self.change != CardFanSwipe.next.rawValue{
                self.change = CardFanSwipe.next.rawValue
            }
        })
        .preference(key: FanSwipedPreferenceKey.self, value: self.change)
        .frame(width: self.width,alignment: .topLeading)
    }
    
    var body: some View {
        if let safeHeight = self.height{
            self.mainBody
            .basicCard(size:.init(width: self.width, height: safeHeight))
        }else{
            self.mainBody
                .basicCard()
        }
    }
}

struct CrybsePoll_Previews: PreviewProvider {
    static var previews: some View {
        CrybsePoll(poll: .init(question: "Testing, Do you like this ?", options: ["Yes , Ofc Course !","No, Not At All !"]), width: totalWidth - 40)
            .basicCard(size: .zero,background: AnyView(mainBGView))
    }
}
