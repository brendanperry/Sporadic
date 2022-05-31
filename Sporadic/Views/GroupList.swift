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
    var items: [GridItem] = Array(repeating: .init(.fixed(175), spacing: 0), count: 2)
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "Groups", alignment: .leading, type: .medium)
                .padding()
            
            LazyVGrid(columns: items, spacing: 25) {
                ForEach(groups) { group in
                    NavigationLink(
                        destination: GroupOverview()
                            .navigationBarHidden(true)
                            .navigationTitle("")
                    ) {
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
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 35, height: 35, alignment: .leading)
                    .foregroundColor(group.backgroundColor.getColor())
                
                Text(group.emoji)
            }
            .frame(maxWidth: 125, alignment: .leading)
            .padding([.horizontal, .top])
            
            textHelper.GetTextByType(key: "", alignment: .leading, type: .largeBody, prefix: group.name)
                .padding(.horizontal)
                .frame(height: 50)
                .lineLimit(2)
            
            HStack(spacing: 0) {
                textHelper.GetTextByType(key: "EditGroup", alignment: .leading, type: .small)
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 7, alignment: .leading)
                    .foregroundColor(Color(uiColor: UIColor.lightGray))
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 5)
        }
        .background(Color.white)
        .cornerRadius(10)
        .frame(width: 150, height: 150)
        .shadow(radius: 3)
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
