typealias FMgr = FontManager
struct FontManager {
    
    // dynamic font sizes
    struct dynamicSize {
        public static var largeTitle    : CGFloat   = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        public static var title         : CGFloat   = UIFont.preferredFont(forTextStyle: .title1).pointSize
        // repeat for all the dynamic sizes
    }
    
    // App Supplied Fonts
    struct Quicksand {
        static let familyRoot   = "Quicksand"
        
        // weights
        static let heavy        = bold
        static let bold         = "\(familyRoot)-Bold"
        static let semibold     = "\(familyRoot)-SemiBold"
        static let medium       = regular
        static let regular      = "\(familyRoot)-Regular"
        static let thin         = light
        static let light        = "\(familyRoot)-Light"
        static let ultralight   = light
        
        // dynamic sizes
        static let largeTitle   : Font = Font.custom(FMgr.Quicksand.bold, size: FMgr.dynamicSize.largeTitle)
        // repeat for other sizes
        
    }

    // structs for other fonts

}