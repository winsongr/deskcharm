import SwiftUI

@MainActor
final class Rope: ObservableObject {
    struct Node {
        var position: CGPoint
        var previous: CGPoint
    }

    @Published private(set) var nodes: [Node] = []

    private var anchor: CGPoint
    private var segment: CGFloat
    private let steps = 30
    private let gravity: CGFloat = 0.16
    private let drag: CGFloat = 0.991

    var breeze: CGFloat = 0

    private var timer: Timer?
    private var impulse: CGFloat = 0
    private var clock: Double = 0

    init(anchor: CGPoint, length: CGFloat, links: Int = 16) {
        self.anchor = anchor
        self.segment = length / CGFloat(links - 1)
        self.nodes = (0..<links).map { index in
            let point = CGPoint(x: anchor.x, y: anchor.y + CGFloat(index) * segment)
            return Node(position: point, previous: point)
        }
    }

    var tip: CGPoint { nodes.last?.position ?? anchor }

    var tipDirection: CGVector {
        guard nodes.count >= 2 else { return CGVector(dx: 0, dy: 1) }
        let a = nodes[nodes.count - 2].position
        let b = nodes[nodes.count - 1].position
        let dx = b.x - a.x
        let dy = b.y - a.y
        let length = max(sqrt(dx * dx + dy * dy), 0.0001)
        return CGVector(dx: dx / length, dy: dy / length)
    }

    var tipAngle: Double {
        let direction = tipDirection
        return -atan2(direction.dx, direction.dy) * 180 / .pi
    }

    func beadCenter(radius: CGFloat) -> CGPoint {
        let direction = tipDirection
        return CGPoint(
            x: tip.x + direction.dx * radius,
            y: tip.y + direction.dy * radius
        )
    }

    func start() {
        let timer = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.step() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func frame(atDistance distance: CGFloat) -> (point: CGPoint, tangent: CGVector) {
        var remaining = max(distance, 0)
        for index in 0..<(nodes.count - 1) {
            let a = nodes[index].position
            let b = nodes[index + 1].position
            let dx = b.x - a.x
            let dy = b.y - a.y
            let length = max(sqrt(dx * dx + dy * dy), 0.0001)

            if remaining <= length {
                let t = remaining / length
                return (
                    CGPoint(x: a.x + dx * t, y: a.y + dy * t),
                    CGVector(dx: dx / length, dy: dy / length)
                )
            }
            remaining -= length
        }
        return (tip, tipDirection)
    }

    func resize(length: CGFloat) {
        segment = length / CGFloat(nodes.count - 1)
        settle()
    }

    func reanchor(to point: CGPoint) {
        anchor = point
        settle()
    }

    private func settle() {
        impulse = 0
        for index in nodes.indices {
            let point = CGPoint(x: anchor.x, y: anchor.y + CGFloat(index) * segment)
            nodes[index] = Node(position: point, previous: point)
        }
    }

    func nudge(by delta: CGFloat) {
        impulse += min(max(delta * 0.30, -5), 5)
    }

    private func step() {
        clock += 1.0 / 120.0
        let gust = breeze == 0
            ? 0
            : breeze * CGFloat(sin(clock * 0.62) * 0.75 + sin(clock * 1.7) * 0.25)

        for index in nodes.indices where index > 0 {
            var node = nodes[index]
            let vx = (node.position.x - node.previous.x) * drag
            let vy = (node.position.y - node.previous.y) * drag

            node.previous = node.position
            node.position.x += vx + gust * CGFloat(index)
            node.position.y += vy + gravity
            nodes[index] = node
        }

        if impulse != 0 {
            nodes[nodes.count - 1].position.x += impulse
            impulse = 0
        }

        for _ in 0..<steps {
            solve()
        }
    }

    private func solve() {
        nodes[0].position = anchor
        nodes[0].previous = anchor

        for index in 0..<(nodes.count - 1) {
            let a = nodes[index].position
            let b = nodes[index + 1].position

            let dx = b.x - a.x
            let dy = b.y - a.y
            let distance = max(sqrt(dx * dx + dy * dy), 0.0001)
            let correction = (distance - segment) / distance

            let ox = dx * correction * 0.5
            let oy = dy * correction * 0.5

            if index == 0 {
                nodes[index + 1].position.x -= ox * 2
                nodes[index + 1].position.y -= oy * 2
            } else {
                nodes[index].position.x += ox
                nodes[index].position.y += oy
                nodes[index + 1].position.x -= ox
                nodes[index + 1].position.y -= oy
            }
        }
    }
}

struct RopePath: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        path.move(to: points[0])
        for index in 1..<(points.count - 1) {
            let current = points[index]
            let next = points[index + 1]
            let mid = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
            path.addQuadCurve(to: mid, control: current)
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}

struct CordStrand: Shape {
    var points: [CGPoint]
    var phase: Double
    var amplitude: CGFloat
    var twistLength: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        var marks: [CGFloat] = [0]
        var total: CGFloat = 0
        for index in 1..<points.count {
            total += hypot(
                points[index].x - points[index - 1].x,
                points[index].y - points[index - 1].y
            )
            marks.append(total)
        }
        guard total > 1 else { return path }

        let samples = max(Int(total / 2.5), 12)

        for sample in 0...samples {
            let travelled = total * CGFloat(sample) / CGFloat(samples)

            var segment = 1
            while segment < marks.count - 1 && marks[segment] < travelled {
                segment += 1
            }

            let a = points[segment - 1]
            let b = points[segment]
            let span = max(marks[segment] - marks[segment - 1], 0.0001)
            let t = min(max((travelled - marks[segment - 1]) / span, 0), 1)

            let dx = (b.x - a.x) / span
            let dy = (b.y - a.y) / span

            let wave = sin(Double(travelled / twistLength) * 2 * .pi + phase)
            let offset = amplitude * CGFloat(wave)

            let point = CGPoint(
                x: a.x + (b.x - a.x) * t - dy * offset,
                y: a.y + (b.y - a.y) * t + dx * offset
            )

            if sample == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        return path
    }
}
