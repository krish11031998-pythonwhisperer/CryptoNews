//
//  CrybPostGen.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/12/2021.
//

import SwiftUI

struct CrybPostGen: View {
    @EnvironmentObject var context:ContextData
    @State var text:String = ""
    @State var showKeyboard:Bool = true
    
    
    
    
    
    var body: some View {
        Container(heading: "Add CrybPost", width: totalWidth, ignoreSides: false, onClose: self.onClose) { w in
            self.header
            TextField("", text: $text)
                .frame(width: w, alignment: .center)
        }
    }
}

extension CrybPostGen{

    var userProfile:ProfileData?{
        return self.context.user.user
    }

    func onClose(){
        if self.context.addPost{
            self.context.addPost.toggle()
        }
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10) {
            ImageView(url: self.userProfile?.img, width: totalWidth  * 0.05, height: totalWidth * 0.05, contentMode: .fill, alignment: .center, clipping: .circleClipping)
            MainText(content: self.userProfile?.userName ?? "", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }
    }
    
}

struct CrybPostGen_Previews: PreviewProvider {
    static var previews: some View {
        CrybPostGen()
    }
}
