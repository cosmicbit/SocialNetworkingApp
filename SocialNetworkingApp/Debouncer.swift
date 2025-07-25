//
//  Debouncer.swift
//  SocialNetworkingApp
//
//  Created by Philips on 16/07/25.
//

import Foundation

/// A generic Debouncer class that delays the execution of a closure.
class Debouncer {
    private let delay: TimeInterval // The time interval to wait before executing the action
    private var workItem: DispatchWorkItem? // The current work item to be executed
    private let queue: DispatchQueue // The dispatch queue on which to execute the action

    /// Initializes a new Debouncer instance.
    ///
    /// - Parameters:
    ///   - delay: The time interval (in seconds) to wait after the last event before executing the action.
    ///   - queue: The dispatch queue on which the action will be executed. Defaults to the main queue.
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    /// Calls the provided closure after the specified delay,
    /// cancelling any previous pending calls.
    ///
    /// - Parameter action: The closure to be executed.
    func debounce(action: @escaping () -> Void) {
        // Cancel any existing work item to ensure only the last call is processed
        workItem?.cancel()

        // Create a new work item
        let newWorkItem = DispatchWorkItem { [weak self] in
            // Execute the action if the work item has not been cancelled
            guard let self = self, !self.workItem!.isCancelled else { return }
            action()
        }

        workItem = newWorkItem

        // Schedule the new work item for execution after the delay
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }

    /// Invalidates the current debouncer, cancelling any pending work.
    func invalidate() {
        workItem?.cancel()
        workItem = nil
    }

    deinit {
        invalidate() // Ensure any pending work is cancelled when the debouncer is deallocated
    }
}
