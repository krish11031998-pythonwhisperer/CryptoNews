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
    @Published private var _selectedSymbol:String? = nil
    @Published private var _addTxn:Bool = false
    
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
    
    var selectedSymbol:String?{
        get{
            return self._selectedSymbol
        }
        
        set{
            withAnimation(.easeInOut) {
                self._selectedSymbol = newValue
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
    
    var addTxn:Bool{
        get{
            return _addTxn
        }
        set{
            withAnimation(.easeInOut) {
                self._addTxn = newValue
            }
        }
    }
}
