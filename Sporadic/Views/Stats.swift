//
//  Stats.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/2/22.
//

import SwiftUI
import Charts

struct Stats: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 20) {
                    TextHelper.text(key: "Analytics", alignment: .leading, type: .h1)
                        .padding(.top, 50)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            })
            .preferredColorScheme(ColorSchemeHelper().getColorSceme())
            .padding(.top)
            
            NavigationBar(viewRouter: viewRouter)
        }
    }
}

struct Stats_Previews: PreviewProvider {
    static var previews: some View {
        Stats()
    }
}
