//
//  Toast.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/10/24.
//

import SwiftUI

struct Toast<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    let presenter: () -> Presenting
    let content: () -> Content
    let delay: TimeInterval = 2
    
    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }
        
        return GeometryReader { geometry in
            ZStack {
                self.presenter()
                
                ZStack {
                    ZStack {
                        Capsule()
                            .fill(Color.gray)
                        
                        self.content()
                    }
                    .frame(width: geometry.size.width / 1.25, height: geometry.size.height / 10)
                    .opacity(self.isPresented ? 1 : 0)
                }
                .padding(.bottom, 20)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}

#Preview {
    Text("hello")
        .toast(isPresented: .constant(true)) {
            Text("toast Message")
                .foregroundColor(Color.white)
        }
}
