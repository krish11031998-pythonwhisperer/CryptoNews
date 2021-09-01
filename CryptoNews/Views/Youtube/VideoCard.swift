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
    var data:AssetNewsData
    var size:CGSize
    
    init(data:AssetNewsData,size:CGSize){
        self.data = data
        self.size = size
        self._playerState = .init(initialValue: .unstarted)
    }
    
    
    var video_id:String?{
        guard let url = self.data.url,let video_id = url.split(separator: "=").last else {return nil}
        return String(video_id)
    }
    
    
    var videoView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let vw_h = h * 0.65
            VStack(alignment: .leading, spacing: 10){
                ZStack(alignment: .center){
                    YoutubePlayer(size: .init(width: w, height: vw_h), videoID: self.video_id!, playerState: self.$playerState)
                    if self.playerState == .unstarted{
                        ImageView(url: self.data.thumbnail, width: w, height: vw_h, contentMode: .fill, alignment: .center)
                        SystemButton(b_name: "play.fill") {
                            self.playerState = .playing
                        }
                    }
                }.frame(width: w, height: vw_h , alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                MainText(content: self.data.title ?? "No Title", fontSize: 15,color: .white,fontWeight: .medium)
                Spacer()
//                MainText(content: self.data.description ?? "", fontSize: 12, color: .white, fontWeight: .thin)
            }.frame(width: w, height: h, alignment: .topLeading)
            
            
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
    var body: some View {
        self.videoView
    }
}

//struct VideoCard_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoCard()
//    }
//}
