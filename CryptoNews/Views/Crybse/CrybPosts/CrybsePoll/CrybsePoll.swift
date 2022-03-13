//
//  CrybsePoll.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/02/2022.
//

import SwiftUI

struct CrybsePoll: View {
    var poll:CrybsePollData
    var width:CGFloat = .zero
    var height:CGFloat?
    var alertEventChange:Bool = false
    @State var change:String = CardFanSwipe.none.rawValue
    @State var selectedOption:String = ""
    
    init(poll:CrybsePollData,width:CGFloat,height:CGFloat? = nil,alertEventChange:Bool = false){
        self.width = width
        self.poll = poll
        self.height = height
        self.alertEventChange = alertEventChange
    }
    
    
    var headerView:some View{
        MainText(content: self.poll.Question, fontSize: 20, color: .white, fontWeight: .medium)
    }
    
    func optionBuilder(option:String,width:CGFloat) -> some View{
        let isSelected = option == self.selectedOption
        return MainText(content: option, fontSize: 13, color: .white, fontWeight: .regular)
        .padding()
        .frame(width: width, alignment: .leading)
        .buttonclickedhighlight(selected: isSelected)
        .clipContent(clipping: .roundClipping)
        .buttonify {
            if self.selectedOption != option{
                setWithAnimation {
                    self.selectedOption = option
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
