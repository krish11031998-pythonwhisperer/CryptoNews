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
    var smallCard:Bool
    
    init(data:CrybseVideoData,size:CGSize,smallCard:Bool = false){
        self.data = data
        self.size = size
        self.smallCard = smallCard
        self._playerState = .init(initialValue: .unstarted)
    }
    
    func togglePlay(){
        setWithAnimation {
            if self.playerState == .playing{
                self.playerState = .paused
            }else if self.playerState == .paused || self.playerState == .unstarted{
                self.playerState = .playing
            }
        }
    }
    
    var playButton:some View{
        let buttonImg = self.playerState == .playing ? "pause.fill" : "play.fill"
        return SystemButton(b_name: buttonImg, color: .white,haveBG: true,size: .init(width: 10, height: 10), bgcolor: .clear, borderedBG: true,clipping: .circleClipping,action: self.togglePlay)
    }
    
    func imageVideoInfo(size:CGSize) -> some View{
        ZStack(alignment: .center) {
            ImageView(url: self.data.thumbnail, width: size.width, height: size.height, contentMode: .fill, alignment: .top)
            if self.smallCard{
                VStack(alignment: .center, spacing: 10) {
                    MainText(content: self.data.title, fontSize: 17.5, color: .white, fontWeight: .medium)
                        .padding(.horizontal,10)
                        .padding(.vertical)
                        .frame(width: size.width,alignment: .topLeading)
                }
                .background(lightbottomShadow.frame(width: size.width, alignment: .center))
                .frame(width: size.width,height:size.height, alignment: .bottom)
                
            }
            self.playButton
        }
    }
    
    @ViewBuilder func CardDetails(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: self.data.title, fontSize: 15, color: .white, fontWeight: .medium)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(height: 0.5, alignment: .center)
                .padding(.top,10)
                .padding(.bottom,5)
            HStack(alignment: .center, spacing: 5) {
                Spacer()
                SystemButton(b_name: "circle.grid.2x2", color: .white) {
                    print("Hi")
                }
            }
        }.padding(.horizontal,15)
            .padding(.vertical,10)
        .frame(width: w, alignment: .leading)
    }
    
    var videoView:some View{
        let w = self.size.width
        let h = self.size.height
        let vw_h = self.smallCard ? h : 0.65 * h
        return VStack(alignment: .center, spacing: 5){
            ZStack(alignment: .center){
                YoutubePlayer(size: .init(width: w, height: vw_h), videoID: self.data.videoID, playerState: self.$playerState)
                if self.playerState == .unstarted{
                    self.imageVideoInfo(size: .init(width: w, height: vw_h))
                }
            }.frame(width: w, height: vw_h , alignment: .center)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
            if !self.smallCard{
                self.CardDetails(w: w)
            }
        }
        .frame(width: w, alignment: .topLeading)
        .basicCard()
    }
    
    var body: some View {
        self.videoView
    }
}

struct VideoCard_Previews: PreviewProvider {
    static var previews: some View {
        VideoCard(data: CrybseVideoData.test, size: .init(width: totalWidth - 50, height: 350),smallCard: false)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            .background(Color.mainBGColor.ignoresSafeArea())
    }
}
