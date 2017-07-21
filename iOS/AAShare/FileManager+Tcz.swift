//
//  NSFileManager+Tcz.swift
//  AAShare
//
//  Created by Chen Tom on 30/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

public enum FileExtension: String {
    case JPEG = "jpg"
    case MP4 = "mp4"
    case M4A = "m4a"
    case Other = "other"
    
    public var mimeType: String {
        switch self {
        case .JPEG:
            return "image/jpeg"
        case .MP4:
            return "video/mp4"
        case .M4A:
            return "audio/m4a"
        case .Other:
            return "other"
        }
    }
}

public extension FileManager {
    
    public class func tczCachesURL() -> NSURL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
    }
    
    // MARK: Avatar
    
    public class func tczAvatarCachesURL() -> NSURL? {
        
        let fileManager = FileManager.default
        
        let avatarCachesURL = tczCachesURL().appendingPathComponent("avatar_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: avatarCachesURL!, withIntermediateDirectories: true, attributes: nil)
            return avatarCachesURL as NSURL?
        } catch let error {
            print("Directory create: \(error)")
        }
        
        return nil
    }
    
    public class func tczAvatarURLWithName(name: String) -> NSURL? {
        
        if let avatarCachesURL = tczAvatarCachesURL() {
            return avatarCachesURL.appendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)") as NSURL?
        }
        
        return nil
    }
    
    public class func saveAvatarImage(avatarImage: UIImage, withName name: String) -> NSURL? {
        
        if let avatarURL = tczAvatarURLWithName(name: name) {
            let imageData = UIImageJPEGRepresentation(avatarImage, 0.8)
            if FileManager.default.createFile(atPath: avatarURL.path!, contents: imageData, attributes: nil) {
                return avatarURL
            }
        }
        
        return nil
    }
    
    public class func deleteAvatarImageWithName(name: String) {
        if let avatarURL = tczAvatarURLWithName(name: name) {
            do {
                try FileManager.default.removeItem(at: avatarURL as URL)
            } catch let error {
                print("File delete: \(error)")
            }
        }
    }
    
    // MARK: Message
    
    public class func tczMessageCachesURL() -> NSURL? {
        
        let fileManager = FileManager.default
        
        let messageCachesURL = tczCachesURL().appendingPathComponent("message_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: messageCachesURL!, withIntermediateDirectories: true, attributes: nil)
            return messageCachesURL as NSURL?
        } catch let error {
            print("Directory create: \(error)")
        }
        
        return nil
    }
    
    // Image
    
    public class func tczMessageImageURL(withName name: String) -> NSURL? {
        
        if let messageCachesURL = tczMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.JPEG.rawValue)") as NSURL?
        }
        
        return nil
    }
    
    public class func saveMessageImageData(messageImageData: NSData, withName name: String) -> NSURL? {
        
        if let messageImageURL = tczMessageImageURL(withName: name) {
            if FileManager.default.createFile(atPath: messageImageURL.path!, contents: messageImageData as Data, attributes: nil) {
                return messageImageURL
            }
        }
        
        return nil
    }
    
    public class func removeMessageImageFileWithName(name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageImageURL = tczMessageImageURL(withName: name) {
            do {
                try FileManager.default.removeItem(at: messageImageURL as URL)
            } catch let error {
                print("File delete: \(error)")
            }
        }
    }
    
    // Audio
    
    public class func tczMessageAudioURL(withName name: String) -> NSURL? {
        
        if let messageCachesURL = tczMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.M4A.rawValue)") as NSURL?
        }
        
        return nil
    }
    
    public class func saveMessageAudioData(messageAudioData: NSData, withName name: String) -> NSURL? {
        
        if let messageAudioURL = tczMessageAudioURL(withName: name) {
            if FileManager.default.createFile(atPath: messageAudioURL.path!, contents: messageAudioData as Data, attributes: nil) {
                return messageAudioURL
            }
        }
        
        return nil
    }
    
    public class func removeMessageAudioFileWithName(name: String) {
        
        if name.isEmpty {
            return
        }
        
        if let messageAudioURL = tczMessageAudioURL(withName: name) {
            do {
                try FileManager.default.removeItem(at: messageAudioURL as URL)
            } catch let error {
                print("File delete: \(error)")
            }
        }
    }
    
    // Video
    
    public class func tczMessageVideoURL(withName name: String) -> NSURL? {
        
        if let messageCachesURL = tczMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.MP4.rawValue)") as NSURL?
        }
        
        return nil
    }
    
    public class func saveMessageVideoData(messageVideoData: NSData, withName name: String) -> NSURL? {
        
        if let messageVideoURL = tczMessageVideoURL(withName: name) {
            if FileManager.default.createFile(atPath: messageVideoURL.path!, contents: messageVideoData as Data, attributes: nil) {
                return messageVideoURL
            }
        }
        
        return nil
    }
    
    public class func removeMessageVideoFilesWithName(name: String, thumbnailName: String) {
        
        if !name.isEmpty {
            if let messageVideoURL = tczMessageVideoURL(withName: name) {
                do {
                    try FileManager.default.removeItem(at: messageVideoURL as URL)
                } catch let error {
                    print("File delete: \(error)")
                }
            }
        }
        
        if !thumbnailName.isEmpty {
            if let messageImageURL = tczMessageImageURL(withName: thumbnailName) {
                do {
                    try FileManager.default.removeItem(at: messageImageURL as URL)
                } catch let error {
                    print("File delete: \(error)")
                }
            }
        }
    }
    
    // Other
    
    public class func tczOtherCachesURL() -> NSURL? {
        
        let fileManager = FileManager.default
        
        let otherCachesURL = tczCachesURL().appendingPathComponent("other_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: otherCachesURL!, withIntermediateDirectories: true, attributes: nil)
            return otherCachesURL as NSURL?
        } catch let error {
            print("Directory create: \(error)")
        }
        
        return nil
    }
    
    public class func tczOtherURL(withName name: String) -> NSURL? {
        
        if let messageCachesURL = tczMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.Other.rawValue)") as NSURL?
        }
        
        return nil
    }
    
    public class func saveOtherData(otherData: NSData, withName name: String) -> NSURL? {
        
        if let otherURL = tczOtherURL(withName: name) {
            if FileManager.default.createFile(atPath: otherURL.path!, contents: otherData as Data, attributes: nil) {
                return otherURL
            }
        }
        
        return nil
    }
    
    public class func removeOtherFilesWithName(name: String) {
        
        if !name.isEmpty {
            if let otherURL = tczOtherURL(withName: name) {
                do {
                    try FileManager.default.removeItem(at: otherURL as URL)
                } catch let error {
                    print("File delete: \(error)")
                }
            }
        }
    }
    
    // MARK: Clean Caches
    
    public class func cleanCachesDirectory(at cachesDirectoryURL: NSURL) {
        let fileManager = FileManager.default
        
        if let fileURLs = (try? fileManager.contentsOfDirectory(at: cachesDirectoryURL as URL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())) {
            for fileURL in fileURLs {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch let error {
                    print("File delete: \(error)")
                }
            }
        }
    }
    
    public class func cleanAvatarCaches() {
        if let avatarCachesURL = tczAvatarCachesURL() {
            cleanCachesDirectory(at: avatarCachesURL)
        }
    }
    
    public class func cleanMessageCaches() {
        if let messageCachesURL = tczMessageCachesURL() {
            cleanCachesDirectory(at: messageCachesURL)
        }
    }
    
    public class func cleanOtherCaches() {
        if let otherCachesURL = tczOtherCachesURL() {
            cleanCachesDirectory(at: otherCachesURL)
        }
    }
}
