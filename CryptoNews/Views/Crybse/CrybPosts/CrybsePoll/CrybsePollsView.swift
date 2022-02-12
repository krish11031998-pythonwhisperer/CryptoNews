//
//  CrybseApprovedQuestion.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

struct CrybsePollsView: View {
    var postData:CrybPostData
    @State var choosenOption:String = ""
    var width:CGFloat
    
    init(postData:CrybPostData,width:CGFloat){
        self.postData = postData
        self.width = width
    }
    
    var body: some View {
        Container(heading: "Questions", headingDivider: false,headingSize: 18, width: self.width, ignoreSides: true,horizontalPadding: 0) { _ in
            ForEach(Array(self.questions.enumerated()), id:\.offset){ _question in
                let question = _question.element
                CrybsePoll(poll: .init(question: question.key, options: question.value), width: self.width )
            }
        }
    }
}

extension CrybsePollsView{
    
    
    var questions:[String:[String]]{
        return ["First Question" : ["Bullish","Bearish","Fake News"]]
    }
    
    var optionsPoll:[String:Float]{
        return ["Bullish" : 0.5, "Bearish" : 0.3, "Fake News": 0.2]
    }
    
    @ViewBuilder func selectedBG(option:String) -> some View{
        if self.choosenOption != ""{
            Color.mainBGColor.opacity(self.choosenOption == option ? 1 : 0.6)
        }else{
            Color.clear
        }
    }
    
    func approvalQuestion(question:String,options:[String]) -> some View{
        Container(width: self.width, ignoreSides: false, horizontalPadding: 10, verticalPadding: 10, orientation: .vertical) { w in
            MainText(content: question, fontSize: 17.5, color: .black, fontWeight: .semibold).frame(width: w, alignment: .leading)
            ForEach(options, id:\.self) { option in
                self.optionView(width: w, option: option)
                    .buttonify(type: .shadow, clipping: .roundClipping) {
//                        setWithAnimation {
                            self.choosenOption = option
//                        }
                    }
            }
        }.frame(width: self.width, alignment: .topLeading)
        .background(mainLightBGView)
        .clipContent(clipping: .roundCornerMedium)
    }
    
    @ViewBuilder func optionView(width:CGFloat,option:String) -> some View{
        if let pollValue = self.optionsPoll[option]{
            HStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "circle", color: .white,haveBG: false, size: .init(width: 10, height: 10)) {
                    setWithAnimation {
                        self.choosenOption = option
                    }
                }
                MainText(content: option, fontSize: 15, color: self.choosenOption != "" ? .white : .black, fontWeight: .semibold, padding: 10)
            }.padding(10)
                .frame(width: width, alignment: .leading)
                .background(self.selectedBG(option: option).frame(width: CGFloat(pollValue) * width).animation(.easeInOut),alignment: .topLeading)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }
    
}

//struct CrybseApprovedQuestion_Previews: PreviewProvider {
//    static var previews: some View {
//        CrybseApprovedQuestion()
//    }
//}
