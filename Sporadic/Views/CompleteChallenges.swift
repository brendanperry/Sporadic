//
//  CompleteChallenges.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/17/22.
//

import SwiftUI
import CoreData

struct CompleteChallenges: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time)]) var challenges: FetchedResults<Challenge>
    
    var body: some View {
        VStack {
            List(challenges) { challenge in
                Text("\(challenge.oneChallengeToOneActivity?.name ?? "Activity") > \(challenge.amount)")
            }
        }
    }
}

struct CompleteChallenges_Previews: PreviewProvider {
    static var previews: some View {
        CompleteChallenges()
    }
}
