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
            ImageView(url: self.data.thumbnail, width: size.width, height: size.height, contentMode: .fill, alignment: .center)
//            bottomShadow.frame(height: size.height, alignment: .center)
            if self.smallCard{
                bottomShadow.frame(height: size.height, alignment: .center)
                VStack(alignment: .center, spacing: 10) {
                    Spacer()
                    MainText(content: self.data.title, fontSize: 17.5, color: .white, fontWeight: .medium)
                        .padding(12.5)
                        .frame(width: size.width, alignment: .leading)
                }.frame(width: size.width, height: size.height, alignment: .bottom)
            }
            self.playButton
        }
    }
    
    @ViewBuilder func CardDetails(w:CGFloat) -> some View{
        MainText(content: self.data.title, fontSize: 17.5, color: .white, fontWeight: .medium)
            .padding(.horizontal,5)
            .padding(.vertical,12.5)
            .frame(width: w, alignment: .leading)
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(width: w, height: 0.5, alignment: .center).padding(.bottom,25)
    }
    
    var videoView:some View{
        let w = self.size.width
        let h = self.size.height
        let vw_h = self.smallCard ? h : self.data.thumbnailHeight ?? 0.65 * h
        return VStack(alignment: .center, spacing: 5){
            ZStack(alignment: .center){
                YoutubePlayer(size: .init(width: w, height: vw_h), videoID: self.data.videoID, playerState: self.$playerState)
                if self.playerState == .unstarted{
                    self.imageVideoInfo(size: .init(width: w, height: vw_h))
                }
            }.frame(width: w, height: vw_h , alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if !self.smallCard{
                self.CardDetails(w: w)
            }
            
        }
        .frame(width: w, alignment: .topLeading)
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
