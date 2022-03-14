//
//  CrybPostDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/12/2021.
//

import SwiftUI

struct CrybPostDetailView: View {
    @State var postData:CrybPostData
    @State var width:CGFloat = .zero
    @State var postReaction:CrybsePostReaction = .none
    @State var chartIndicator:Int = -1
    @EnvironmentObject var context:ContextData
    
    init(postData:CrybPostData){
        self._postData = .init(wrappedValue: postData)
    }
    
    func loadView(w:CGFloat) -> some View{
        DispatchQueue.main.async {
            if self.width != w{
                self.width = w
            }
        }
        
        return ProgressView()
    }
    
    func onClose(){
        if self.context.selectedPost != nil{
            withAnimation(.easeInOut) {
                self.context.selectedPost = nil
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Container(width: totalWidth,ignoreSides: false, horizontalPadding: 15,verticalPadding: 50,onClose: self.onClose) { w in
                if self.width == .zero{
                    self.loadView(w: w)
                }else{
                    CryptoPostCardView(postData: self.postData,width: self.width)
                    CrybseCurrentView(postData: self.postData, width: self.width)
                    CrybsePostReactionView(rating: self.$postReaction, width: self.width)
                    if self.postData.pollIsValid{
                        CrybsePollsView(postData: self.postData, width: self.width)
                    }
                }
            }.padding(.bottom,150)
                .frame(width: totalWidth, alignment: .center)
        }
    }
}

extension CrybPostDetailView{
    var img_width:CGFloat{
        return self.width * 0.15
    }
    
    func likeButtonHandler(){
        print("Clicked on Like")
    }
    
    func commentButtonHandler(){
        print("Clicked on Comment")
    }
    
    func shareButtonHandler(){
        print("Clicked on Share")
    }
    
    var socialEngagementView:some View{
        let buttons:[(String,String,() -> Void)] = [("heart","Like",self.likeButtonHandler),("message","Comment",self.commentButtonHandler),("square.and.arrow.up","Share",self.shareButtonHandler)]
        return HStack(alignment: .center, spacing: 10) {
            ForEach(buttons, id:\.0) { button in
                SystemButton(b_name: button.0, b_content: button.1, color: .white,haveBG: false, bgcolor: .white, alignment: .horizontal,borderedBG: true,action: button.2)
            }
        }.frame(width: width,alignment: .leading)
    }
}

struct CrybPostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            mainBGView
            ScrollView(.vertical, showsIndicators: false) {
                CrybPostDetailView(postData: .test)
            }
        }.ignoresSafeArea()
        
    }
}
