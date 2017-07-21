//
//  TczStringUtility.swift
//  AAShare
//
//  Created by Chen Tom on 08/11/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func tcz_md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        
        return String(format: hash as String)
    }
    
    func tcz_urlEscapedString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func tcz_utf8EncodedData() -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
    
    func tcz_base64DecodedString() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func tcz_base64EncodedString() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func tcz_isValidMoney() -> Bool {
        let str = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.characters.count == 0 {
            return false
        }
        let expression = "^(-)?(([1-9]{1}\\d*)|([0]{1}))(\\.(\\d){1,2})?$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: self, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, str.characters.count))
        return numberOfMatches != 0
    }
}
