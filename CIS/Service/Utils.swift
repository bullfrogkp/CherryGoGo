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
    
    func convertToShipping(_ shippingMOs: [ShippingMO]) -> [Shipping] {
        
        var shippingArray: [Shipping] = []
        
        var imageDict: [ImageMO: Image] = [:]
        var customerDict: [CustomerMO: Customer] = [:]
        
        for shippingMO in shippingMOs {
            let newShipping = Shipping(city: shippingMO.city!, shippingDate: shippingMO.shippingDate!)
            
            newShipping.createdDatetime = shippingMO.createdDatetime
            newShipping.createdUser = shippingMO.createdUser
            newShipping.updatedDatetime = shippingMO.updatedDatetime
            newShipping.updatedUser = shippingMO.updatedUser
            
            if(shippingMO.status != nil) {
                newShipping.status = shippingMO.status!
            }
            if(shippingMO.boxQuantity != nil) {
                newShipping.boxQuantity = shippingMO.boxQuantity!
            }
            if(shippingMO.comment != nil) {
                newShipping.comment = shippingMO.comment!
            }
            if(shippingMO.deposit != nil) {
                newShipping.deposit = shippingMO.deposit!
            }
            if(shippingMO.feeNational != nil) {
                newShipping.feeNational = shippingMO.feeNational!
            }
            if(shippingMO.feeInternational != nil) {
                newShipping.feeInternational = shippingMO.feeInternational!
            }
            
            newShipping.shippingMO = shippingMO
            
            if(shippingMO.images != nil) {
                for img in shippingMO.images! {
                    let imgMO = img as! ImageMO
                    let newImg = Image(imageFile: imgMO.imageFile!)
                    
                    newImg.createdDatetime = imgMO.createdDatetime
                    newImg.createdUser = imgMO.createdUser
                    newImg.updatedDatetime = imgMO.updatedDatetime
                    newImg.updatedUser = imgMO.updatedUser
                    newImg.changed = false
                    
                    if(imgMO.name != nil) {
                        newImg.name = imgMO.name!
                    }
                    newImg.imageMO = imgMO
                    
                    imageDict[imgMO] = newImg
                    
                    if(newShipping.images == nil) {
                        newShipping.images = []
                    }
                    newShipping.images!.append(newImg)
                }
            }
            
            if(shippingMO.customers != nil) {
                for cus in shippingMO.customers! {
                    let cusMO = cus as! CustomerMO
                    let newCus = Customer(name: cusMO.name!)
                    
                    newCus.createdDatetime = cusMO.createdDatetime
                    newCus.createdUser = cusMO.createdUser
                    newCus.updatedDatetime = cusMO.updatedDatetime
                    newCus.updatedUser = cusMO.updatedUser
                    newCus.changed = false
                    
                    if(cusMO.comment != nil) {
                        newCus.comment = cusMO.comment!
                    }
                    if(cusMO.wechat != nil) {
                        newCus.wechat = cusMO.wechat!
                    }
                    if(cusMO.phone != nil) {
                        newCus.phone = cusMO.phone!
                    }
                    newCus.customerMO = cusMO
                    
                    customerDict[cusMO] = newCus
                    
                    if(newShipping.customers == nil) {
                        newShipping.customers = []
                    }
                    newShipping.customers!.append(newCus)
                }
            }
            
            if(newShipping.images != nil) {
                for img in newShipping.images! {
                    if(img.imageMO!.customers != nil) {
                        for cus in img.imageMO!.customers! {
                            let cusMO = cus as! CustomerMO
                            
                            if(img.customers == nil) {
                                img.customers = []
                            }
                            img.customers!.append(customerDict[cusMO]!)
                        }
                    }
                }
            }
            
            if(newShipping.customers != nil) {
                for cus in newShipping.customers! {
                    if(cus.customerMO!.images != nil) {
                        for img in cus.customerMO!.images! {
                            let imgMO = img as! ImageMO
                            
                            if(cus.images == nil) {
                                cus.images = []
                            }
                            cus.images!.append(imageDict[imgMO]!)
                        }
                    }
                }
            }
            
            if(shippingMO.items != nil) {
                for itm in shippingMO.items! {
                    let itmMO = itm as! ItemMO
                    let itmTypeMO = itmMO.itemType!
                    
                    let itmTypeNameMO = itmTypeMO.itemTypeName!
                    let itmTypeBrandMO = itmTypeMO.itemTypeBrand!
                    let itmTypeName = ItemTypeName(name: itmTypeNameMO.name!)
                    itmTypeName.itemTypeNameMO = itmTypeNameMO
                    let itmTypeBrand = ItemTypeBrand(name: itmTypeBrandMO.name!)
                    itmTypeBrand.itemTypeBrandMO = itmTypeBrandMO
                    let itmType = ItemType(itemTypeName: itmTypeName, itemTypeBrand: itmTypeBrand)
                    itmType.itemTypeMO = itmTypeMO
                    
                    let newItm = Item(itemType: itmType, quantity: itmMO.quantity)
                    newItm.itemType = itmType
                    newItm.createdDatetime = itmMO.createdDatetime
                    newItm.createdUser = itmMO.createdUser
                    newItm.updatedDatetime = itmMO.updatedDatetime
                    newItm.updatedUser = itmMO.updatedUser
                    newItm.changed = false
                    
                    if(itmMO.comment != nil) {
                        newItm.comment = itmMO.comment!
                    }
                    
                    if(itmMO.priceSold != nil) {
                        newItm.priceSold = itmMO.priceSold!
                    }
                    
                    if(itmMO.priceBought != nil) {
                        newItm.priceBought = itmMO.priceBought!
                    }
                    
                    newItm.customer = customerDict[itmMO.customer!]!
                    newItm.image = imageDict[itmMO.image!]!
                    newItm.itemMO = itmMO
                    
                    if(newShipping.items == nil) {
                        newShipping.items = []
                    }
                    newShipping.items!.append(newItm)
                }
            }
            
            shippingArray.append(newShipping)
        }
        
        return shippingArray
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


