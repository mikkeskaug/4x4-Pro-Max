//
//  WorkoutManager.swift
//  4x4 Pro Max
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import Foundation
import HealthKit
import Combine
import WatchKit

class WorkoutManager: NSObject, ObservableObject {
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var heartRate: Double = 0
    @Published var aHeartRate: Double = 0
    @Published var distance: Double = 0
    @Published var speed: Double = 0
    @Published var averageSpeed: Double = 0
    @Published var workoutActive = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentInterval: WorkoutInterval?
    @Published var timeRemaining: TimeInterval = 0
    @Published var showSummary = false
    private var intervalIndex = 0

    private var timer: Timer?
    
    let intervals: [WorkoutInterval] = [
        WorkoutInterval(type: .warmup, name: "Warmup", duration: 5 * 60),
        WorkoutInterval(type: .run, name: "Run 1", duration: 4 * 60),
        WorkoutInterval(type: .jog, name: "Jog 1", duration: 3 * 60),
        WorkoutInterval(type: .run, name: "Run 2", duration: 4 * 60),
        WorkoutInterval(type: .jog, name: "Jog 2", duration: 3 * 60),
        WorkoutInterval(type: .run, name: "Run 3", duration: 4 * 60),
        WorkoutInterval(type: .jog, name: "Jog 3", duration: 3 * 60),
        WorkoutInterval(type: .run, name: "Run 4", duration: 4 * 60),
        WorkoutInterval(type: .cooldown, name: "Cooldown", duration: 5 * 60),
    ]

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        let typesToShare: Set = [HKWorkoutType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }

    func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            session?.delegate = self
            builder?.delegate = self

            workoutActive = true
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { _, _ in }

            startTimer()
            startIntervals()

        } catch {
            print("Couldn't start workout: \(error.localizedDescription)")
        }
    }

    func stopWorkout() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        workoutActive = false

        session?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in
            self.builder?.finishWorkout { _, _ in }
        }
        
        DispatchQueue.main.async {
            self.showSummary = true
        }
        
    }

    func pauseWorkout() {
        timer?.invalidate()
        workoutActive = false
        session?.pause()
    }
    
    func startIntervals() {
        intervalIndex = 0
        advanceToNextInterval()
    }
    
    func advanceToNextInterval() {
        guard intervalIndex < intervals.count else {
            stopWorkout()
            return
        }

        let interval = intervals[intervalIndex]
        currentInterval = interval
        timeRemaining = interval.duration

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.intervalIndex += 1
                self.advanceToNextInterval()
            }
        }
        WKInterfaceDevice().play(.notification)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.elapsedTime += 1
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout error: \(error.localizedDescription)")
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }

            if quantityType.identifier == HKQuantityTypeIdentifier.heartRate.rawValue {
                if let stat = workoutBuilder.statistics(for: quantityType),
                   let value = stat.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())),
                   let value2 = stat.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())){
                    DispatchQueue.main.async {
                        self.heartRate = value
                        self.aHeartRate = value2
                    }
                }
            }
            else if quantityType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
                print("Distance data received")
                if let stat = workoutBuilder.statistics(for: quantityType),
                   let value = stat.sumQuantity()?.doubleValue(for: HKUnit.meter()) {
                    DispatchQueue.main.async {
                        print("Total distance: \(value) meters")
                        self.distance = value
                    }
                }
            }
            else if quantityType.identifier == HKQuantityTypeIdentifier.runningSpeed.rawValue {
                if let stat = workoutBuilder.statistics(for: quantityType),
                   let value = stat.mostRecentQuantity()?.doubleValue(for: HKUnit.meter().unitDivided(by: .second())),
                   let value2 = stat.averageQuantity()?.doubleValue(for: HKUnit.meter().unitDivided(by: .second()))
                    {
                    DispatchQueue.main.async {
                        self.speed = value
                        self.averageSpeed = value2
                    }
                    
                }
                
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
