//
//  CrybsePollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/03/2022.
//

import SwiftUI

enum CrybsePostReaction:String{
    case like = "like"
    case dislike = "dislike"
    case bullish = "bullish"
    case bearish = "bearish"
    case fakeNews = "fake News"
    case verifiedNews = "verified News"
    case speculation = "speculation"
    case theory = "just a theory"
    case none = ""
}

extension CrybsePostReaction{
    static func buttonImg(reaction:CrybsePostReaction) -> String{
        switch(reaction){
        case .like:
            return "👍"
        case .dislike:
            return "👎"
        case .bullish:
            return "🐂"
        case .bearish:
            return "🐻"
        case .fakeNews:
            return "❌"
        case .verifiedNews:
            return "✅"
        default:
            return "😐"
        }
    }
}

struct CrybsePostReactionView: View {
    @Binding var rating:CrybsePostReaction
    var width:CGFloat
        
    init(rating:Binding<CrybsePostReaction> = .constant(.verifiedNews),width:CGFloat = totalWidth - 30){
        self._rating = rating
        self.width = width
    }
    
    var allRatings:[CrybsePostReaction]{
        return [
            .like,
            .dislike,
            .bullish,
            .bearish,
            .fakeNews,
            .verifiedNews,
            .theory
        ]
    }
    
    var widthCard:CGFloat{
        return self.width * 0.5
    }
    
    var minWidthCard:CGFloat{
        return self.width * 0.25
    }
    
    var column:[GridItem]{
        return [.init(.adaptive(minimum: minWidthCard), spacing: 10, alignment: .leading)]
    }
    
    func ratingView(rating:CrybsePostReaction) -> some View{
        return MainSubHeading(heading: CrybsePostReaction.buttonImg(reaction: rating), subHeading: rating.rawValue.capitalized, headingSize: 20, subHeadingSize: 13, headColor: .white, subHeadColor: .white,orientation: .horizontal,bodyWeight: .medium, spacing: 15,alignment: .center)
    }
    
    @ViewBuilder func RatingViewButton(rating:CrybsePostReaction) -> some View{
        let ratingButtonView =
        VStack(alignment: .center, spacing: 10) {
            self.ratingView(rating: rating)
            if self.rating != .none{
                MainText(content: "\(Int.random(in: 10...90))", fontSize: 15, color: .white, fontWeight: .medium)
            }
        }
        .padding().frame(minWidth:self.minWidthCard,maxWidth: .infinity,alignment: .center)
        .basicCard()
        
        
        ratingButtonView
            .buttonclickedhighlight(selected: self.rating == rating)
            
    }
    
    var RatingView:some View{
        LazyVGrid(columns: self.column, alignment: .leading, spacing: 10) {
            ForEach(Array(self.allRatings.enumerated()), id:\.offset) {
                _rating in
                let rating = _rating.element
                self.RatingViewButton(rating: rating)
                    .buttonify {
                        if self.rating == rating{
                            self.rating = .none
                        }else if self.rating != rating{
                            self.rating = rating
                        }
                    }
            }
        }
    }
    
    var body: some View {
        Container(heading: "Reaction", headingColor: .white, headingDivider: false, headingSize: 18, width: self.width, ignoreSides: true,horizontalPadding: 0) { _ in
            RatingView
        }
    }
}

struct CrybsePollView_Previews: PreviewProvider {
    
    @State static var selectedReaction:CrybsePostReaction = .none
    
    
    static var previews: some View {
        CrybsePostReactionView(rating: CrybsePollView_Previews.$selectedReaction)
            .background(mainBGView.frame(width: totalWidth, height: totalHeight, alignment: .center).ignoresSafeArea())
            
    }
}
