//
//  Memojis.swift
//  Sporadic
//
//  Created by Brendan Perry on 2/5/25.
//

import SwiftUI

struct Memojis: View {
    var body: some View {
        HStack {
            Spacer()
            
            Image("Memoji1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 100)
            
            Spacer()
            
            Image("Memoji2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 100)
            
            Spacer()
        }
    }
}

#Preview {
    Memojis()
}
