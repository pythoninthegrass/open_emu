// Copyright (c) 2021, OpenEmu Team
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the OpenEmu Team nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Cocoa

/// Animated dark background for the setup wizard.
///
/// Originally rendered via QCRenderer + CAOpenGLLayer (OE Startup.qtz).
/// QCRenderer was removed in macOS 14 (Sonoma), causing a silent blank
/// background. Replaced with a CAEmitterLayer particle animation that
/// approximates the original atmospheric feel and works on macOS 14+ ARM64.
final class SetupAssistantBackgroundView: NSView {

    private var emitterLayer: CAEmitterLayer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
    }

    override func layout() {
        super.layout()
        guard !bounds.isEmpty else { return }

        if let emitter = emitterLayer {
            emitter.frame = layer!.bounds
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
            emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        } else {
            layer?.backgroundColor = CGColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1)
            setupEmitter()
        }
    }

    private func setupEmitter() {
        guard let rootLayer = layer else { return }

        let emitter = CAEmitterLayer()
        emitter.frame = rootLayer.bounds
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        emitter.renderMode = .additive

        // Primary drifting particles
        let primary = CAEmitterCell()
        primary.birthRate = 1.2
        primary.lifetime = 22
        primary.lifetimeRange = 8
        primary.velocity = 28
        primary.velocityRange = 12
        primary.emissionLongitude = .pi / 2  // upward (CA: y increases upward)
        primary.emissionRange = .pi / 6
        primary.scale = 0.10
        primary.scaleRange = 0.06
        primary.alphaSpeed = -0.04
        primary.color = CGColor(red: 0.55, green: 0.65, blue: 1.0, alpha: 0.45)
        primary.contents = makeParticleImage()
        primary.name = "primary"

        // Larger, very faint background glow particles
        let glow = CAEmitterCell()
        glow.birthRate = 0.4
        glow.lifetime = 30
        glow.lifetimeRange = 10
        glow.velocity = 14
        glow.velocityRange = 6
        glow.emissionLongitude = .pi / 2
        glow.emissionRange = .pi / 8
        glow.scale = 0.30
        glow.scaleRange = 0.10
        glow.alphaSpeed = -0.025
        glow.color = CGColor(red: 0.3, green: 0.4, blue: 0.9, alpha: 0.12)
        glow.contents = makeParticleImage()
        glow.name = "glow"

        emitter.emitterCells = [primary, glow]
        rootLayer.addSublayer(emitter)
        emitterLayer = emitter
    }

    private func makeParticleImage() -> CGImage? {
        let side = 16
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let ctx = CGContext(
            data: nil,
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: side * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else { return nil }

        let center = CGPoint(x: CGFloat(side) / 2, y: CGFloat(side) / 2)
        let radius = CGFloat(side) / 2
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                CGColor(red: 1, green: 1, blue: 1, alpha: 1),
                CGColor(red: 1, green: 1, blue: 1, alpha: 0),
            ] as CFArray,
            locations: [0, 1]
        ) else { return nil }

        ctx.drawRadialGradient(
            gradient,
            startCenter: center, startRadius: 0,
            endCenter: center, endRadius: radius,
            options: []
        )
        return ctx.makeImage()
    }
}
