//
//  GroupWidget.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/30/22.
//

import SwiftUI

struct GroupList: View {
    let textHelper = TextHelper()
    let groups: [UserGroup]
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)
    @State var isActive = false
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack(spacing: 0) {
            textHelper.GetTextByType(key: "Groups", alignment: .leading, type: .h2, color: .primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: items, spacing: 0) {
                ForEach(groups) { group in
                    NavigationLink(destination: GroupOverview(viewModel: GroupOverviewViewModel(group: group))) {
                        GroupWidget(group: group)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
        }
    }
}

struct GroupWidget: View {
    let group: UserGroup
    let textHelper = TextHelper()
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Circle()
                    .frame(minWidth: 40, maxWidth: 50, minHeight: 40, maxHeight: 75, alignment: .leading)
                    .foregroundColor(group.backgroundColor.getColor())
                
                Text(group.emoji)
                    .font(.system(size: 25))
            }
            .padding([.horizontal, .top])
            
            textHelper.GetTextByType(key: "", alignment: .leading, type: .h3, prefix: group.name)
                .padding(.horizontal)
                .frame(height: 50)
                .lineLimit(2)
            
            HStack(alignment: .bottom, spacing: 0) {
                textHelper.GetTextByType(key: "EditGroup", alignment: .leading, type: .challengeGroup)
                    .frame(width: 70)
                
                VStack {
                    Spacer()
                    Image("View Group Carrot Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: -2)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 18)
            .padding([.horizontal, .bottom])
        }
        .background(Color("Panel"))
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .shadow(radius: 3)
        .padding()
    }
}

struct GroupList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GroupList(groups: [
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "The Wow M9s",
                    users: []),
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "The Biking Gang",
                    users: []),
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "Penny Mable Penny Mable Penny",
                    users: [])
            ])
            GroupList(groups: [
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "The Wow M9s",
                    users: []),
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "The Biking Gang",
                    users: []),
                UserGroup(
                    activities: [],
                    challenges: [],
                    daysOfTheWeek: [],
                    deliveryTime: Date(),
                    emoji: "🍉",
                    backgroundColor: .blue,
                    name: "Penny Mable Penny Mable Penny",
                    users: [])
            ])
            .previewDevice("iPhone 12 Pro Max")
            .previewInterfaceOrientation(.portraitUpsideDown)
        }
    }
}
