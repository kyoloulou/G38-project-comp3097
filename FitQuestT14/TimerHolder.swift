import Foundation

final class TimerHolder {
    private var timer: Timer?

    func start(interval: TimeInterval, block: @escaping () -> Void) {
        stop()
        let t = Timer(timeInterval: interval, repeats: true) { _ in
            block()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit { stop() }
}
