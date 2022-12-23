//
//  LoadingBar.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/22/22.
//

import SwiftUI

struct LoadingBar: View {
    @State var isAnimating = false
    
    var body: some View {
        LinearGradient(colors: [Color("GroupOption3"), Color("GroupOption5")], startPoint: isAnimating ? .trailing : .leading, endPoint: .trailing)
            .mask {
                RoundedRectangle(cornerRadius: 16)
                    .padding()
                    .frame(height: 50)
            }
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                withAnimation {
                    isAnimating = true
                }
            }
    }
}

struct LoadingBar_Previews: PreviewProvider {
    static var previews: some View {
        LoadingBar()
    }
}
