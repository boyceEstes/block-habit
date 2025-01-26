//
//  ParticleModifier.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/25.
//

import SwiftUI

extension View {
    
    func particleModifier(
        systemImage: String,
        font: Font,
        status: Bool,
        activeTint: Color,
        inactiveTint: Color
    ) -> some View {
        self
            .modifier(
                ParticleModifier(
                    systemImage: systemImage,
                    font: font,
                    status: status,
                    activeTint: activeTint,
                    inactiveTint: inactiveTint
                )
            )
    }
}

fileprivate struct ParticleModifier: ViewModifier {
    
    var systemImage: String
    var font: Font
    var status: Bool
    var activeTint: Color
    var inactiveTint: Color
    // View Properties
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        
                        // We need to place them based on their values
                        Image(systemName: "\(systemImage)")
                            .foregroundStyle(status ? activeTint : inactiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                        // Only visible whenever status is true
                            .opacity(status ? 1 : 0)
                            .animation(.none, value: status)
                    }
                }
            }
            .onAppear {
                if particles.isEmpty {
                    for index in 0...15 {
                        let particle = Particle()
                        particles.append(particle)
                    }
                }
            }
            .onChange(of: status) { _, newValue in
                if !newValue {
                    // reset animation
                    for index in particles.indices {
                        particles[index].reset()
                    }
                } else {
                    // Activate the particles by setting position and scale
                    for index in particles.indices {
                        // Random X & Y Calculation Based on Index
                        let total: CGFloat = CGFloat(particles.count)
                        let progress = CGFloat(index) / total
                        
                        let maxX: CGFloat = progress > 0.5 ? 100 : -100
                        let maxY: CGFloat = 60
                        
                        // This would be always somewhere between 0-0.5 the max
                        let randomX = ((progress > 0.5) ? progress - 0.5 : progress) * maxX
                        let randomY = (((progress > 0.5) ? progress - 0.5 : progress) * maxY) + 35
                        
                        let randomScale: CGFloat = .random(in: 0.35...1)
                        
                        
                        
                        withAnimation(
//                            .interactiveSpring(
//                                response: 0.6,
//                                dampingFraction: 0.7,
//                                blendDuration: 0.7
//                            )
                            .spring(.smooth)
                        ) {
                            
                            let extraRandomX: CGFloat = (progress < 0.5) ? .random(in: 0...10) : .random(in: -10...0)
                            let extraRandomY: CGFloat = .random(in: 0...30)
                            
                            particles[index].randomX = randomX + extraRandomX
                            particles[index].randomY = randomY - extraRandomY
                            
                        }
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            particles[index].scale = randomScale
                        }
                        
                        // Removing particles based on index
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)
                            .delay(0.25 + (Double(index) * 0.005))) {
                            
                            particles[index].scale = 0.001
                        }
                    }
                }
            }
            
    }
}
