//
//  UIManagerData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/09/2021.
//

import Foundation
import SwiftUI


class ContextData:ObservableObject{
    @Published private var _selectedCurrency:AssetData? = nil
    @Published private var _selectedNews:AssetNewsData? = nil
    
    
    var selectedCurrency:AssetData?{
        get{
            return self._selectedCurrency
        }
        
        set{
            withAnimation(.easeInOut(duration: 0.5)) {
                self._selectedCurrency = newValue
            }
        }
    }
    
    var selectedNews:AssetNewsData?{
        get{
            return self._selectedNews
        }
        
        set{
            withAnimation(.easeInOut(duration: 0.5)) {
                self._selectedNews = newValue
            }
        }
    }
}
