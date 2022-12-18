//
//  LoadingIndicator.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/13/22.
//

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        ZStack {
            VStack {
                ProgressView()
            }
            .frame(width: 75, height: 75, alignment: .center)
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("LoadingBackground"))
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator()
    }
}
