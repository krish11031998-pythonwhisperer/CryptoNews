//
//  CrybseAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/12/2021.
//

import Foundation


class CrybseAPI:DAPI{
    
    override var baseComponent: URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "crybse.herokuapp.com"
        return uC
    }
    
}
