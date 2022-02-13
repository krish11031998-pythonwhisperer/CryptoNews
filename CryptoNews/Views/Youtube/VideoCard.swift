//
//  VideoCard.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 28/08/2021.
//

import SwiftUI
import youtube_ios_player_helper

struct VideoCard: View {
    @State var playerState:YTPlayerState
//    var data:AssetNewsData
    var data:CrybseVideoData
    var size:CGSize
    
    init(data:CrybseVideoData,size:CGSize){
        self.data = data
        self.size = size
        self._playerState = .init(initialValue: .unstarted)
    }
    
    func imageVideoInfo(size:CGSize) -> some View{
        ZStack(alignment: .center) {
            ImageView(url: self.data.thumbnail, width: size.width, height: size.height, contentMode: .fill, alignment: .center)
            bottomShadow.frame(height: size.height, alignment: .center)
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                MainText(content: self.data.title, fontSize: 17.5, color: .white, fontWeight: .medium)
                    .padding(12.5)
                    .frame(width: size.width - 25, alignment: .leading)
            }.padding()
            .frame(width: size.width, height: size.height, alignment: .bottom)
            SystemButton(b_name: "play.fill", color: .white,haveBG: true,size: .init(width: 10, height: 10), bgcolor: .clear, borderedBG: true,clipping: .circleClipping) {
                self.playerState = .playing
            }
        }
    }
    
    var videoView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let vw_h = h * 1
            VStack(alignment: .leading, spacing: 10){
                ZStack(alignment: .center){
                    YoutubePlayer(size: .init(width: w, height: vw_h), videoID: self.data.videoID, playerState: self.$playerState)
                        .onTapGesture {
                            if self.playerState == .playing{
                                self.playerState = .paused
                            }
                        }
                    if self.playerState == .unstarted || self.playerState == .paused{
                        self.imageVideoInfo(size: .init(width: w, height: vw_h))
                    }
                }.frame(width: w, height: vw_h , alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }.frame(width: w, height: h, alignment: .topLeading)
            
            
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
    var body: some View {
        self.videoView
    }
}

struct VideoCard_Previews: PreviewProvider {
    static var previews: some View {
        VideoCard(data: CrybseVideoData.test, size: .init(width: totalWidth - 50, height: 350))
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            .background(Color.mainBGColor.ignoresSafeArea())
    }
}
