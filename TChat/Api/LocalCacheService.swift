//
//  LocalCacheService.swift
//  TChat
//
//  Created by Артем Сарычев on 16.06.21.
//

import Foundation

class LocalCacheService {
    static let shared = LocalCacheService()
    var users: Set<User> = []
    var messages: [Message] = []
    var inboxes: [Inbox] = []
}
