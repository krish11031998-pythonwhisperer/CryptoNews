//
//  VideoDetailView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/04/2022.
//

import SwiftUI
import youtube_ios_player_helper

struct VideoDetailView: View {
    var video:CrybseNews
    var width:CGFloat
    @State var playerState:YTPlayerState = .unstarted
    
    init(video:CrybseNews,width:CGFloat){
        self.video = video
        self.width = width
    }
    
    @ViewBuilder func videoImageView(w:CGFloat) -> some View{
        if let imgUrl = self.video.image_url{
            if self.playerState != .unstarted,let videoID = self.video.VideoID{
                YoutubePlayer(size: .init(width: w, height: totalHeight * 0.35), videoID: videoID   , playerState: self.$playerState)
            }else if self.playerState == .unstarted{
                ImageView(url: imgUrl, width: w,height: totalHeight * 0.35, contentMode: .fill, alignment: .center, isPost: false, clipping: .roundClipping)
            }
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    func videoStateView(w:CGFloat) -> some View{
        SystemButton(b_name: self.playerState != .playing ? "play.fill" : "pause.fill", color: .white, size: .init(width: 25, height: 25), bgcolor: .clear, borderedBG: true, clipping: .circleClipping) {
            if self.playerState != .playing{
                self.playerState = .playing
            }else{
                self.playerState = .paused
            }
        }
    }
    
    @ViewBuilder func videoInfoView(w:CGFloat) -> some View{
        if let title = self.video.title{
            MainText(content: title, fontSize: 22.5, color: .white, fontWeight: .medium)
        }
        HStack(alignment: .center, spacing: 10) {
            MainSubHeading(heading: self.video.SourceName, subHeading: self.video.Date, headingSize: 17, subHeadingSize: 13, headColor: .white, subHeadColor: .white.opacity(0.5), orientation: .vertical, headingWeight: .medium, bodyWeight: .medium, spacing: 10, alignment: .topLeading)
            Spacer()
            if let sentiment = self.video.sentiment{
                let color = sentiment == "Positive" ? Color.green : sentiment == "Negative" ? Color.red : Color.gray
                MainText(content: sentiment, fontSize: 12, color: color, fontWeight: .medium, padding: 10)
                    .basicCard(background: BlurView.thinLightBlur.background(color).anyViewWrapper())
                    .borderCard(color: color, clipping: .roundClipping)
            }
        }
    }
    
    @ViewBuilder func videoDescriptionView(w:CGFloat) -> some View{
        if let description = self.video.text{
            MainText(content: description, fontSize: 20, color: .white, fontWeight: .medium)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical,15)
        }else{
            Color.clear
                .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    var body: some View {
        Container(width:self.width) { w in
            self.videoInfoView(w: w)
            self.videoImageView(w: w)
            self.videoStateView(w: w)
            self.videoDescriptionView(w: w)
        }
    }
}

//struct VideoDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoDetailView()
//    }
//}
