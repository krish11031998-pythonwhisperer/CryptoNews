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
        Container(heading: "Questions", headingDivider: false, headingSize: 18, width: self.width, ignoreSides: true, horizontalPadding: 0, orientation: .vertical, aligment: .leading, spacing: 10) { w in
            ForEach(Array(self.polls.enumerated()),id:\.offset){ _poll in
                CrybsePoll(poll: _poll.element, width: w)
            }
        }
    }
}

extension CrybsePollsView{
    
    var polls:Array<CrybsePollData>{
        return [self.postData.Poll]
    }
}
