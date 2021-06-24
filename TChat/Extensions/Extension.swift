//
//  Extension.swift
//  TChat
//
//  Created by Артем Сарычев on 29.04.21.
//

import Foundation
import SDWebImage

extension String {
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 300, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil)
    }
}

func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){ return "1 year ago"
        } else { return "Last year" }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){ return "1 month ago"
        } else { return "Last month" }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!)w ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){ return "1w ago"
        } else { return "Last week" }
    } else if (components.day! >= 2) {
        return "\(components.day!)d ago"
    } else if (components.day! >= 1){
        if (numericDates){ return "1d ago"
        } else { return "Yesterday" }
    } else if (components.hour! >= 2) {
        return "\(components.hour!)h ago"
    } else if (components.hour! >= 1){
        if (numericDates){ return "1h ago"
        } else { return "An hour ago" }
    } else if (components.minute! >= 2) {
        return "\(components.minute!)m ago"
    } else if (components.minute! >= 1){
        if (numericDates){ return "1m ago"
        } else { return "A minute ago" }
    } else if (components.second! >= 3) {
        return "\(components.second!)s ago"
    } else { return "Just now" }
}

extension UIImageView {
    
    func loadImage(_ urlString: String?, onSuccess: ((UIImage) -> Void)?  = nil) {
        self.image = UIImage()
        guard let string = urlString else {
            return
        }
        guard let url = URL(string: string) else {
            return
        }
        
        self.sd_setImage(with: url) { (image, error, type, url) in
            if onSuccess != nil, error == nil {
                onSuccess!(image!)
            }
        }
    }
}


extension UIColor {
    convenience init(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            self.init(red: r, green: g, blue: b, alpha: a)
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Double {
    func convertDate() -> String {
        var string = ""
        let date: Date = Date(timeIntervalSince1970: self)
        let calendrier = Calendar.current
        let formatter = DateFormatter()
        if calendrier.isDateInToday(date) {
            string = ""
            formatter.timeStyle = .short
        } else if calendrier.isDateInYesterday(date) {
            string = "Yesterday: "
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .short
        }
        let dateString = formatter.string(from: date)
        return string + dateString
    }
}

extension String {
    var hashString: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}
