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
    @State var selectedOption:String = ""
    
    init(poll:CrybsePollData,width:CGFloat){
        self.width = width
        self.poll = poll
    }
    
    
    var headerView:some View{
        MainText(content: self.poll.Question, fontSize: 20, color: .white, fontWeight: .medium)
    }
    
    func optionBuilder(option:String,width:CGFloat) -> some View{
        let isSelected = option == self.selectedOption
//        let borderColor = isSelected ? AnyView(RoundedRectangle(cornerRadius: Clipping.roundClipping.rawValue).stroke(Color.mainBGColor, lineWidth: 1.25)) :AnyView(RoundedRectangle(cornerRadius: Clipping.roundClipping.rawValue).stroke(Color.gray, lineWidth: 1.25))
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
    
    var body: some View {
        Container(heading: self.poll.Question, headingColor: .white, headingDivider: false, headingSize: 20, width: self.width,ignoreSides: false, verticalPadding: 15) { w in
            ForEach(self.poll.Options , id: \.self) { option in
                self.optionBuilder(option: option, width: w)
            }
        }.basicCard(size: .zero)
    }
}

struct CrybsePoll_Previews: PreviewProvider {
    static var previews: some View {
        CrybsePoll(poll: .init(question: "Testing, Do you like this ?", options: ["Yes , Ofc Course !","No, Not At All !"]), width: totalWidth - 40)
            .basicCard(size: .zero,background: AnyView(mainBGView))
    }
}
