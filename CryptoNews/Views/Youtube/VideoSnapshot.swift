//
//  VideoSnapshot.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/05/2022.
//

import SwiftUI
import youtube_ios_player_helper

struct VideoSnapshot: View {
    var videoData:CrybseNews
    var width:CGFloat
    var height:CGFloat
    @State var playerState:YTPlayerState
    
    init(videoData:CrybseNews,width:CGFloat,height:CGFloat){
        self.videoData = videoData
        self.width = width
        self.height = height
        self._playerState = .init(initialValue:.unstarted)
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
        return SystemButton(b_name: buttonImg, color: .white,size: .init(width: 10, height: 10), bgcolor: .clear,action: self.togglePlay)
            .padding(7.5)
            .background(Circle().fill(Color.black.opacity(0.75)))
    }
    

    @ViewBuilder func headerView(w:CGFloat) -> some View{
        if let safeVideoID = self.videoData.VideoID{
            ZStack(alignment: .center) {
                YoutubePlayer(size: .init(width: w, height: self.height * 0.7), videoID: safeVideoID, playerState: self.$playerState)
                    .frame(width: w, height: self.height * 0.7, alignment: .center)
                    .clipContent(clipping: .squareClipping)
                    .opacity(self.playerState == .unstarted ? 0 : 1)
                if let imgUrl = self.videoData.image_url,self.playerState == .unstarted{
                    ImageView(url: imgUrl, width: w, height: self.height * 0.7, contentMode: .fill, alignment: .center, clipping: .squareClipping)
                    self.playButton
                    
                }
            }
        }
    }
    
    @ViewBuilder func footerView(w:CGFloat) -> some View{
        if let title = self.videoData.title, let creator = self.videoData.source_name{
            MainText(content: title, fontSize: 17.5, color: .white, fontWeight: .medium, padding: 5)
                .makeAdjacentView(orientation: .vertical, alignment: .leading, position: .top,spacing: 0) {
                    MainText(content: creator, fontSize: 13, color: .white.opacity(0.5), fontWeight: .semibold,padding: 5)
                }
                .frame(width: w, height: self.height * 0.3 - 5, alignment: .topLeading)
        }
    }
    
    var body: some View {
        Container(width:self.width,ignoreSides: true,verticalPadding: 0,spacing: 5){w in
            self.headerView(w: w)
            self.footerView(w: w)
        }.frame(width: self.width, height: self.height,alignment: .topLeading)
    }
}

struct VideoSnapshot_Previews: PreviewProvider {
    static var previews: some View {
        if let safeVideo = CrybseSocialHighlightsAPI.loadStaticSocialHighlights()?.videos?.first{
            VideoSnapshot(videoData: safeVideo,width: totalWidth * 0.95,height: totalHeight * 0.35)
                .background(Color.AppBGColor)
        }else{
            ProgressView()
        }
        
    }
}
