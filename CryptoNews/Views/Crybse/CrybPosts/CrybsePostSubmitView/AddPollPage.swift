//
//  AddPollPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/01/2022.
//

import SwiftUI

class AddPollForm:ObservableObject{
    @Published var question:String = ""
    @Published var optionsCount:Int = 2
    @Published var options:[String] = []
}


struct AddPollPage: View {
    
    @StateObject var pollForm:AddPollForm
    
    var width:CGFloat
    init(width:CGFloat = totalWidth - 20){
        self.width = width
        self._pollForm = .init(wrappedValue: .init())
    }
    
    func optionView(placeHolder:String,w:CGFloat,completion: @escaping (String) -> Void) -> some View{
        Container(headingDivider: false, width: w, horizontalPadding: 5, verticalPadding: 0,orientation: .horizontal) { inner_w in
            SystemButton(b_name: "circle", haveBG: false, size: .init(width: 7.5,height: 7.5), bgcolor: .clear) {}
            StylizedTextEditor(placeHolder:placeHolder,limit: 50, includeIndicator: false, width: inner_w - 25,style: .init(color: .black, fontSize: 12))
                .onPreferenceChange(StylizedTextEditorTextPreferenceKey.self,perform: completion)
        }.frame(width: w, alignment: .trailing)
    }
    
    
    
    var body: some View {
        Container(heading: "Add Poll", headingColor: .black, headingDivider: true, width: self.width) { w in
            StylizedTextEditor(placeHolder:"Add Question",limit: 50, includeIndicator: false, width: w,style: .init(color: .black, fontSize: 18))
                .onPreferenceChange(StylizedTextEditorTextPreferenceKey.self) { newQuestion in
                    if self.pollForm.question != newQuestion{
                        self.pollForm.question = newQuestion
                    }
                }
            ForEach(Array(0..<self.pollForm.optionsCount), id:\.self){ idx in
                self.optionView(placeHolder: "Add Option", w: w) { newOption in
                    DispatchQueue.main.async {
                        if self.pollForm.options.count <= idx {
                            self.pollForm.options.append(newOption)
                        }else{
                            self.pollForm.options[idx] = newOption
                        }
                    }
                }
            }
            
            TabButton(width: w, height: 15, title: "Add More Options", textColor: .white) {
                setWithAnimation {
                    self.pollForm.optionsCount += 1
                }
            }.padding(.vertical)
            
        }
        .frame(width: self.width, alignment: .topLeading)
        .background(mainLightBGView)
        .clipContent(clipping: .roundClipping)
    }
}

struct AddPollPage_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            mainBGView
            AddPollPage().padding(.top,100)
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
            .ignoresSafeArea()
    }
}
