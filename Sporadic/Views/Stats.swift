//
//  Stats.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/2/22.
//

import SwiftUI

struct Stats: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            Text("Stats")
            NavigationBar(viewRouter: viewRouter)
        }
    }
}

struct Stats_Previews: PreviewProvider {
    static var previews: some View {
        Stats()
    }
}
