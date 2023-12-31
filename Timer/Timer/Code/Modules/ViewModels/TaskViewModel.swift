//
//  TaskViewModel.swift
//  Timer
//
//  Created by Ziya on 8/4/23.
//

import UIKit

class TaskViewModel {
    
    private var task: Task!
    
    private let taskTypes: [TaskType] = [
    TaskType(symbolName: "star", typeName: "Priority"),
    TaskType(symbolName: "iphone", typeName: "Develop"),
    TaskType(symbolName: "gamecontroller", typeName: "Gaming"),
    TaskType(symbolName: "wand.and.stars.inverse", typeName: "Editing")
    ]
    
    private var selectedIndex = -1 {
        didSet {
            self.task.taskType = self.getTaskTypes()[selectedIndex]
        }
    }
    
    private var hours = Box(0)
    private var minutes = Box(0)
    private var seconds = Box(0)
    
    
    init() {
        task = Task(taskName: "", taskDescription: "", seconds: 0, taskType: .init(symbolName: "", typeName: ""), timeStamp: 0)
    }
    
    func setSelectedIndex(to value: Int) {
        self.selectedIndex = value
    }
    
    func setTaskName(to value: String) {
        self.task.taskName = value
    }
    
    func setTaskDescription(to value: String) {
        self.task.taskDescription = value
    }
    
    func getSelectedIndex() -> Int {
        self.selectedIndex
    }
    
    func getTask() -> Task {
        self.task
    }
     
    func getTaskTypes() -> [TaskType] {
        return self.taskTypes
    }
    
    func setHours(to value: Int) {
        self.hours.value = value
    }
    
    func setMinutes(to value: Int) {
        var newMinute = value
        
        if newMinute > 60 {
            newMinute -= 60
            hours.value += 1
        }
        
        self.minutes.value = newMinute
    }
    
    func setSeconds(to value: Int) {
        var newSeconds = value
        
        if value > 60 {
             newSeconds -= 60
            minutes.value += 1
        }
        
        if minutes.value >= 60 {
            minutes.value -= 60
            hours.value += minutes.value
        }
        
        self.seconds.value = newSeconds
    }
    
    func getHours() -> Box<Int> {
        return self.hours
    }
    
    func getMinutes() -> Box<Int> {
        return self.minutes
    }
    
    func getSeconds() -> Box<Int> {
        return self.seconds
    }
    
    func computeSeconds() {
        self.task.seconds = (hours.value * 3600) + (minutes.value + 60) + seconds.value
        self.task.timeStamp = Date().timeIntervalSince1970
        print(task.seconds)
    }
    
    func isTaskNotEmpty() -> Bool {
        if (!task.taskName.isEmpty && !task.taskDescription.isEmpty && selectedIndex != -1 && (self.seconds.value > 0 || self.minutes.value > 0 || self.hours.value > 0)) {
            return true
        }
        return false
    }
    
}
 
