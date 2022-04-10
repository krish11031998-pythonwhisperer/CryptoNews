//
//  VideoSectionCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/02/2022.
//

import SwiftUI

struct VideoSectionCard: View {
    var video:CrybseVideoData
    var size:CGSize
    
    init(video:CrybseVideoData,size:CGSize){
        self.video = video
        self.size = size
    }
    
    var imgView:some View{
        ImageView(url: self.video.thumbnail ?? "", width: self.size.width, height: self.size.height, contentMode: .fill, alignment: .center)
    }
    
    var detailsOverlayView:some View{
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            SystemButton(b_name: "play.fill", color: .white, haveBG: false,size: .init(width: 10, height: 10), bgcolor: .clear, borderedBG: true, clipping: .circleClipping) {
                print("(DEBUG) Play Button Pressed")
            }
            MainText(content: self.video.title, fontSize: 13.5, color: .white, fontWeight: .medium)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                .fill(Color.white)
                .frame(height: 0.75, alignment: .center)
        }
        .padding()
        .frame(width: self.size.width, height: self.size.height, alignment: .topLeading)
        .background(lightbottomShadow)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            self.imgView
            self.detailsOverlayView
        }
//        .clipContent(clipping: .roundCornerMedium)
    }
}

//struct VideoSectionCard_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoSectionCard(video: CrybseVideoData.test, size: .init(width: totalWidth * 0.8, height: totalHeight * 0.35))
//    }
//}
