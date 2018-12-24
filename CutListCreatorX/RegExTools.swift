//
//  RegExTools.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Foundation

func matches(for regex: String, in text: String) -> [String] {
    // https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    // TODO Update to Swift 4
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

extension String {
    func matchingStrings(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        
        var collectMatches: Array<String> = []
        for match in results {
            // range at index 0: full match
            // range at index 1: first capture group
            let substring = nsString.substring(with: match.rangeAt(1))
            collectMatches.append(substring)
        }
        return collectMatches
    }
}
