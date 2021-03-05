//
//  extentions.swift
//  Sortify
//
//  Created by Hani Tawil on 29/01/2021.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

extension Set {
    func containsOneOf(members: Array<Element>) -> Bool {
        for member in members {
            if self.contains(member) {
                return true
            }
        }
        
        return false
    }
    
    mutating func insertAll(contentsof: Array<Element>) {
        for item in contentsof {
            self.insert(item)
        }
    }
}

extension Array where Element == Artists {
    func getByID(id: String) -> Artists? {
        for item in self.enumerated() {
            if item.element.id == id {
                return item.element
            }
        }
        
        return nil
    }
}
