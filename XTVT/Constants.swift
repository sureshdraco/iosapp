//
//  Constants.swift
//  XTVT
//
//  Created by Admin on 12/27/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation


struct Constants {
    static let APP_ID:String = "id959379869"

    static let WEB_URL:String = "http://tours.ciedge.com.my/"
    
    static let getPlacesByPage:String = "app/services/listPlaces"
    static let getPlaceDetails:String = "app/services/getPlaceDetails"
    static let getNewsInfoByPage:String = "app/services/listNewsInfo"
    static let registerDevice:String = "app/services/insertGcm"
    static let getImagePath:String = "uploads/place/"
    static let getNewsImagePath:String = "uploads/news/"
    
    static let LIMIT_LOADMORE:Int = 40
    
    static let catNumAll:Int = 0 //All Places
    static let catNumBeach:Int = 1 //Beach & Water Activities
    static let catNumFood:Int = 2 //Local Cuisines
    static let catNumClimbing:Int = 3 //Climbing Activities
    static let catNumCaving:Int = 4 //Caving Activities
    static let catNumCultural:Int = 5 //Cultural Activities
    static let catNumPark:Int = 6 //Parks & Trails
    static let catNumTopTourist:Int = 7 //Top Tourist Activities
    static let catNumFeatured:Int = 8 //Featured Activities
    static let catNumOthers:Int = 9 //Other Activities
    static let catNumFavorite:Int = 10 //Favorite
    static let catNumNewsInfo:Int = 11 //News Info Activites
}
