//
//  ContentView.swift
//  drop
//
//  Created by Raj Dhakate on 07/03/21.
//

import SwiftUI

struct ContentView: View {
    
    // letter offset to track the letter position
    @State private var letterOffset = CGSize.zero
    
    // envelope origin
    @State private var envelopeOrigin = CGPoint.zero
    
    // drag view animation y axis
    @State var dragAnimationYAxisValue : CGFloat = 100
    
    // drag view animation y axis offset
    @State var dragAnimationYAxisOffset: CGFloat = 100
    
    // flags to keep tracking of app states
    
    // is user dragging the letter
    @State var isDragging: Bool = false
    
    // has user dragged the letter
    @State var isDragged: Bool = false
    
    // is letter in position (over the envelope)
    @State var isInPosition: Bool = false
    
    // for fade animation of anvelope
    @State private var fadeAnimationToggle = false
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                
                if !isDragged {
                    Image("letter")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: reader.size.width/2, height: reader.size.width/2)
                        .offset(self.letterOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.isDragging = true
                                    self.letterOffset = gesture.translation
                                    
                                    if abs(self.letterOffset.height) >= self.envelopeOrigin.y {
                                        self.isInPosition = true
                                    } else {
                                        self.isInPosition = false
                                    }
                                }

                                .onEnded { _ in
                                    
                                    if abs(self.letterOffset.height) >= self.envelopeOrigin.y {
                                        self.fadeAnimationToggle.toggle()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            self.isDragged = true
                                            self.fadeAnimationToggle.toggle()
                                        }
                                    } else {
                                        self.letterOffset = .zero
                                    }
                                }
                        ).zIndex(1)
                } else {
                    Spacer()
                    
                    Button(action: {
                        self.fadeAnimationToggle.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.isDragged = false
                            self.isInPosition = false
                            self.letterOffset = .zero
                            
                            self.fadeAnimationToggle.toggle()
                        }
                    }, label: {
                        Image("add-file")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: reader.size.width/5, height: reader.size.width/5)
                    })
                }
                
                if !isDragging {
                    
                    VStack {
                        Image("drag")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reader.size.width/4, height: reader.size.width/4)
                        
                        Text("Drag mail over the envelope...")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .position(x: reader.size.width/2, y: dragAnimationYAxisValue)
                    .onAppear() {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                            withAnimation() {
                                self.dragAnimationYAxisOffset = -self.dragAnimationYAxisOffset
                                self.dragAnimationYAxisValue = self.dragAnimationYAxisValue - self.dragAnimationYAxisOffset
                            }
                        }
                    }
                }
                
                if isInPosition && !isDragged {
                    VStack {
                        Image("paper-plane")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: reader.size.width/4, height: reader.size.width/4)
                        
                        Text("- release to send -")
                            .font(.body)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                            .padding()
                    }
                }
                
                Spacer()
                
                GeometryReader { envelopeReader in
                    Image(isDragged ? "close-envelope" : "open-envelope")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(fadeAnimationToggle ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25))
                        .onAppear {
                            let rect = envelopeReader.frame(in: .named("kMainScreen"))
                            self.envelopeOrigin = rect.origin
                        }
                }
                .frame(width: reader.size.width/2, height: reader.size.width/2)
                
            }
            .coordinateSpace(name: "kMainScreen")
            .frame(width: reader.size.width)
//            .preferredColorScheme(.dark)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
