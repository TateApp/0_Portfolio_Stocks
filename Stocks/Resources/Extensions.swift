import UIKit

extension UIColor {
    
    convenience init(rbg red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let _red : CGFloat = CGFloat(red) / 255
        let _green : CGFloat = CGFloat(green) / 255
        let _blue : CGFloat = CGFloat(blue) / 255
        
        self.init(red: _red, green: _green, blue: _blue, alpha : alpha)
        
    }
}
extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "YYYY-MM-dd"
        
        return formatter
    }()
}
