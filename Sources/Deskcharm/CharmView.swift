import SwiftUI

struct CharmView: View {
    @ObservedObject var rope: Rope
    @ObservedObject var settings: Settings

    private var size: CGFloat { settings.beadSize }

    var body: some View {
        ZStack(alignment: .topLeading) {
            cord

            binding

            pendant
                .frame(width: size, height: size)
                .contentShape(Circle())
                .onTapGesture { rope.nudge(by: 11) }
                .rotationEffect(.degrees(rope.tipAngle))
                .position(rope.beadCenter(radius: size / 2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var pendant: some View {
        switch settings.charm {
        case .nazar:
            NazarBead(size: size)
        case .photo:
            if let photo = settings.photo {
                PhotoLocket(image: photo, size: size)
            }
        default:
            Text(settings.charm.glyph)
                .font(.system(size: size * 0.82))
                .shadow(color: .black.opacity(0.45), radius: 9, y: 4)
        }
    }

    private var cordPoints: [CGPoint] {
        rope.nodes.map(\.position) + [rope.beadCenter(radius: size / 2)]
    }

    private var cord: some View {
        ZStack {
            RopePath(points: cordPoints)
                .stroke(
                    Color(red: 0.34, green: 0.24, blue: 0.12).opacity(0.85),
                    style: StrokeStyle(lineWidth: 4.4, lineCap: .round)
                )
                .blur(radius: 1.1)

            strand(phase: 0, light: true)
            strand(phase: .pi, light: false)
        }
        .allowsHitTesting(false)
    }

    private func strand(phase: Double, light: Bool) -> some View {
        CordStrand(points: cordPoints, phase: phase, amplitude: 1.15, twistLength: 9)
            .stroke(
                LinearGradient(
                    colors: light
                        ? [Color(red: 0.87, green: 0.72, blue: 0.44), Color(red: 0.70, green: 0.54, blue: 0.29)]
                        : [Color(red: 0.62, green: 0.47, blue: 0.24), Color(red: 0.47, green: 0.34, blue: 0.17)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 1.9, lineCap: .round)
            )
    }

    private var binding: some View {
        let length = settings.cordLength
        return ZStack {
            ForEach(0..<4, id: \.self) { index in
                let place = rope.frame(atDistance: length - 26 + CGFloat(index) * 3.4)
                let angle = atan2(place.tangent.dy, place.tangent.dx) * 180 / .pi

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.52, green: 0.38, blue: 0.19),
                                Color(red: 0.34, green: 0.24, blue: 0.11),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 8.4, height: 2.5)
                    .rotationEffect(.degrees(angle - 90))
                    .position(place.point)
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 1.2, y: 0.8)
        .allowsHitTesting(false)
    }
}

struct NazarBead: View {
    let size: CGFloat

    private let deep = Color(red: 0.035, green: 0.196, blue: 0.494)
    private let porcelain = Color(red: 0.965, green: 0.980, blue: 1.0)
    private let iris = Color(red: 0.157, green: 0.592, blue: 0.839)
    private let pupil = Color(red: 0.027, green: 0.055, blue: 0.098)

    var body: some View {
        ZStack {
            Circle().fill(deep)

            Circle()
                .fill(porcelain)
                .scaleEffect(0.46)
                .blur(radius: 0.4)

            Circle()
                .fill(iris)
                .scaleEffect(0.28)
                .blur(radius: 0.4)

            Circle()
                .fill(pupil)
                .scaleEffect(0.135)
                .blur(radius: 0.3)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.26), .white.opacity(0.04), .clear],
                        center: UnitPoint(x: 0.30, y: 0.24),
                        startRadius: 0,
                        endRadius: size * 0.58
                    )
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.clear, .clear, .black.opacity(0.30)],
                        center: .center,
                        startRadius: size * 0.36,
                        endRadius: size * 0.52
                    )
                )

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.55),
                            .white.opacity(0.08),
                            .black.opacity(0.30),
                            .black.opacity(0.55),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.2
                )

            Ellipse()
                .fill(.white.opacity(0.72))
                .frame(width: size * 0.30, height: size * 0.17)
                .rotationEffect(.degrees(-34))
                .offset(x: -size * 0.21, y: -size * 0.25)
                .blur(radius: 5.5)

            Ellipse()
                .fill(.white.opacity(0.85))
                .frame(width: size * 0.10, height: size * 0.055)
                .rotationEffect(.degrees(-34))
                .offset(x: -size * 0.235, y: -size * 0.27)
                .blur(radius: 1.2)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.50), radius: 12, y: 5)
    }
}

struct PhotoLocket: View {
    let image: NSImage
    let size: CGFloat

    private var rim: CGFloat { max(size * 0.07, 4) }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.84, blue: 0.55),
                            Color(red: 0.72, green: 0.54, blue: 0.26),
                            Color(red: 0.52, green: 0.37, blue: 0.16),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size - rim * 2, height: size - rim * 2)
                .clipShape(Circle())

            Circle()
                .strokeBorder(.black.opacity(0.25), lineWidth: 1)
                .padding(rim)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.30), .white.opacity(0.05), .clear],
                        center: UnitPoint(x: 0.30, y: 0.24),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .padding(rim)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.50), radius: 12, y: 5)
    }
}
