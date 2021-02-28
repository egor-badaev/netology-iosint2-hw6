//
//  TimerProvider.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 27.02.2021.
//

import UIKit

protocol TimerProviderDelegate: AnyObject {
    func reloadData()
    func updateTimer(countdown: Int)
}

class TimerProvider {
    
    // MARK: Public properties
    var countdown: Int { wholeSecondsToReload }
    weak var delegate: TimerProviderDelegate?

    // MARK: Private properties
    private lazy var timer: Timer = {
        let timer = Timer(timeInterval: 0.1,
                          target: self,
                          selector: #selector(timerUpdated(_:)),
                          userInfo: nil,
                          repeats: true)
        return timer
    }()
    
    private var timeInterval: TimeInterval
    private var reloadInterval: TimeInterval
    private var secondsPassed: Double = 0
    private lazy var wholeSecondsToReload: Int = Int(reloadInterval.rounded(.up))

    // MARK: - Public methods
    init(timeInterval: TimeInterval, reloadInterval: TimeInterval) {
        self.timeInterval = timeInterval
        self.reloadInterval = reloadInterval
    }
    
    func startTimer() {
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    // MARK: Private methods
    @objc private func timerUpdated(_ sender: Timer) {
        secondsPassed += sender.timeInterval
        wholeSecondsToReload = Int((reloadInterval - secondsPassed).rounded(.up))
        delegate?.updateTimer(countdown: wholeSecondsToReload)

        if wholeSecondsToReload == 0 {
            secondsPassed = 0.0
            delegate?.reloadData()
        }
    }
}
