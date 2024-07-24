//
//  PatientTask.swift
//
//
//  Created by Samantha Gatt on 7/23/24.
//

import SimpleNetworking

// TODO: Try cancelling a task and seeing what is returned

/// Task that will wait to be manually executed, and will only be kicked off once(*) while inflight (subsequent calls will wait for current task to finish executing). Task will start executing again (upon call to `execute()`) if previous executions have been completed.
class PatientTask<T> {
    private var task: Task<T, Never>?
    private let executable: () async -> T
    
    init(executable: @escaping () async -> T) {
        self.task = nil
        self.executable = executable
    }
    
    func execute() async -> T {
        let scopedExecutable = executable
        if let task {
            // Task is already running
            return await task.value
        } else {
            let newTask = Task {
                return await scopedExecutable()
            }
            // (*) Assigning the newTask in two steps allows for a very small window of time where the executable is running but PatientTask ins't aware
            // The alternative is to directly assign the new `Task { }` to `task` but then you'd have to use a force unwrap to return `await task!.value`
            task = newTask
            let value = await newTask.value
            task = nil
            return value
        }
    }
}
