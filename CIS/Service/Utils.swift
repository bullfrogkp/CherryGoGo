//
//  Utils.swift
//  CIS
//
//  Created by Kevin Pan on 2019-09-19.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation
import BSImagePicker
import Photos
import CoreData

final class Utils {
    
    static let shared: Utils = Utils()
    
    private init() { }
    
    func getAssetThumbnail(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func getOriginalImage(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func getUser() -> String {
        return "pank"
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getItemTypeNameMO(name: String) -> ItemTypeNameMO? {

        var itemTypeNameArray: [ItemTypeNameMO] = [ItemTypeNameMO]()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicateItemTypeName = NSPredicate(format: "name = %@", name)
        let requestItemTypeName : NSFetchRequest<ItemTypeNameMO> = ItemTypeNameMO.fetchRequest()
        requestItemTypeName.predicate = predicateItemTypeName
        requestItemTypeName.includesPendingChanges = false

        do {
            itemTypeNameArray = try context.fetch(requestItemTypeName)
        } catch {
            print("Error while fetching data: \(error)")
        }

        if(itemTypeNameArray.count == 1) {
            return itemTypeNameArray[0]
        } else {
            return nil
        }
    }
    
    func getItemTypeBrandMO(brand: String) -> ItemTypeBrandMO? {
        var itemTypeBrandArray: [ItemTypeBrandMO] = [ItemTypeBrandMO]()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicateItemTypeBrand = NSPredicate(format: "name = %@", brand)
        let requestItemTypeBrand : NSFetchRequest<ItemTypeBrandMO> = ItemTypeBrandMO.fetchRequest()
        requestItemTypeBrand.predicate = predicateItemTypeBrand
        requestItemTypeBrand.includesPendingChanges = false

        do {
            itemTypeBrandArray = try context.fetch(requestItemTypeBrand)
        } catch {
            print("Error while fetching data: \(error)")
        }

        if(itemTypeBrandArray.count == 1) {
            return itemTypeBrandArray[0]
        } else if(itemTypeBrandArray.count == 0) {
            return nil
        } else {
            print("Error while fetching data: \(itemTypeBrandArray.count)")
            return nil
        }
    }
    
    func getItemTypeMO(name: String, brand: String) -> ItemTypeMO? {
    
        var itemTypeArray : [ItemTypeMO] = [ItemTypeMO]()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "itemTypeName.name = %@ AND itemTypeBrand.name = %@", name, brand)
        let request : NSFetchRequest<ItemTypeMO> = ItemTypeMO.fetchRequest()
        request.predicate = predicate
        request.includesPendingChanges = false

        do {
            itemTypeArray = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }

        if(itemTypeArray.count == 1) {
            return itemTypeArray[0]
        } else if(itemTypeArray.count == 0) {
            return nil
        } else {
            print("Error while fetching data: \(itemTypeArray.count)")
            return nil
        }
    }

    func getCustomerMO(name: String) -> CustomerMO? {
        var dataList : [CustomerMO] = [CustomerMO]()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "name = %@", name)
        let request : NSFetchRequest<CustomerMO> = CustomerMO.fetchRequest()
        request.predicate = predicate
        request.includesPendingChanges = false

        do {
            dataList = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }

        if(dataList.count == 1) {
            return dataList[0]
        } else if(dataList.count == 0) {
            return nil
        } else {
            print("Error while fetching data: \(dataList.count)")
            return nil
        }
    }
}

extension String {
    func isIncludeChinese()->Bool {
        for ch in self.unicodeScalars {
            //Chinese character range:0x4e00 ~ 0x9fff
            if (0x4e00<ch.value&&ch.value<0x9fff) {
                return true
            }
        }
        return false
    }
    
    func transformToPinyin()->String {
        let stringref = NSMutableString(string:self) as CFMutableString
        //converted to pinyin with phonetic transcription
        CFStringTransform(stringref, nil, kCFStringTransformToLatin, false);
        //remove the phonetic symbol
        CFStringTransform(stringref, nil, kCFStringTransformStripCombiningMarks, false);
        let pinyin=stringref as String
        return pinyin
    }
    
    func transformToPinyinWithoutBlank()->String {
        var pinyin=self.transformToPinyin()
        //remove spaces
        pinyin=pinyin.replacingOccurrences(of: " ", with:"")
        return pinyin
    }
    
    func getPinyinHead()->String {
        //convert string to uppercase
        let pinyin=self.transformToPinyin().capitalized
        var headpinyinstr=""
        //get all capital letters
        for ch in pinyin {
            if ch <= "z" && ch >= "a" {
                headpinyinstr.append (ch)
            }
        }
        return headpinyinstr
    }
    
    func getCapitalLetter()->String {
        var pinyin = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(pinyin != "") {
            if(self.isIncludeChinese()) {
                pinyin = self.transformToPinyin().capitalized
            } else {
                pinyin = self
            }
            return "\(Array(pinyin)[0])"
        } else {
            return ""
        }
    }
}

extension ImageMO {
    @objc var createdMonthAndYear: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY年MM月"
            return dateFormatter.string(from: self.createdDatetime!)
        }
    }
}

extension ItemMO {
    @objc var formattedShippingDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY年MM月dd日"
            return dateFormatter.string(from: self.shipping!.shippingDate!)
        }
    }
}

func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15

    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIColor {
    
    class func randomColor() -> UIColor {

        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

struct ImageMOStruct {
    var imageMO: ImageMO
    var itemMOStructArray: [ItemMOStruct]
    var status: String
}
struct CustomerMOStruct {
    var customerMO: CustomerMO
    var itemMOStructArray: [ItemMOStruct]
    var status: String
}

struct ItemMOStruct {
    var itemMO: ItemMO
    var status: String
}
