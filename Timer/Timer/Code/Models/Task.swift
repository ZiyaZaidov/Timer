//
//  Task.swift
//  Timer
//
//  Created by Ziya on 8/4/23.
//

import Foundation

struct TaskType {
    let symbolName: String
    let typeName: String
}

struct Task {
    var taskName: String
    var taskDescription: String
    var seconds: Int
    var taskType: TaskType
    var timeStamp: Double
}

enum CountdownState {
    case suspend
    case pause
    case running
}
