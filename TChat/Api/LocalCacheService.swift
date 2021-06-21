//
//  LocalCacheService.swift
//  TChat
//
//  Created by Артем Сарычев on 16.06.21.
//

import Foundation

class LocalCacheService {
    static let shared = LocalCacheService() 
    var inboxes: [Inbox] = []
}
