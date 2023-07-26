//
//  ViewSizes.swift
//  Meal
//
//  Created by Loic D on 03/01/2023.
//

import SwiftUI

class ViewSizes {
    static func _5() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 2
        }
        return 5
    }
    
    static func _10() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 4
        }
        return 10
    }
    
    static func _15() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 5
        }
        return 15
    }
    
    static func _30() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 15
        }
        return 30
    }
    
    static func _50() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 30
        }
        return 50
    }
    
    static func _70() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 10
        }
        return 70
    }
    
    static func _100() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 70
        }
        return 100
    }
    
    static func _120() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 80
        }
        return 120
    }
    
    static func _200() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 100
        }
        return 200
    }
    
    static func _mealType_spacerWidth() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 5
        }
        return 20
    }
    
    static func _largeTitle() -> Font {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .title2
        }
        return .largeTitle
    }
    
    static func _title() -> Font {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .title3
        }
        return .title
    }

    static func _MealList_GridColumns() -> [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [GridItem(.flexible())]
        }
        return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
}
