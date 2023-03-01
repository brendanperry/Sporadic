//
//  GroupWidget.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/30/22.
//

import SwiftUI
import CloudKit

struct GroupList: View {
    @Binding var groups: [UserGroup]
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 2)
    @State var isActive = false
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextHelper.text(key: "Groups", alignment: .leading, type: .challengeAndSettings, color: .primary)
                .padding(.horizontal)
                .padding(.bottom)

            LazyVGrid(columns: items, spacing: 17) {
                if isLoading && groups.isEmpty {
                    GroupLoadingWidget()
                }
                else {
                    ForEach($groups) { group in
                        NavigationLink(destination: GroupOverview(group: group)) {
                            GroupWidget(group: group.wrappedValue)
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                    }

                    AddNewGroup(groups: $groups)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AddNewGroup: View {
    @Binding var groups: [UserGroup]
    
    var body: some View {
        NavigationLink(destination: CreateGroupView(groups: $groups)) {
            ZStack {
                Rectangle()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(Color("Panel"))
                    .shadow(radius: 3)
                    .cornerRadius(10)
                
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
            }
        }
        .buttonStyle(ButtonPressAnimationStyle())
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .shadow(radius: 3)
        .padding()
    }
}

struct GroupLoadingWidget: View {
    @State var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Circle()
                .foregroundColor(GroupBackgroundColor.six.getColor())
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 75, alignment: .leading)
                .padding([.horizontal, .top])
            
            LoadingBar()
                .frame(height: 20)
                .padding()
        }
        .background(Color("Panel"))
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .shadow(radius: 3)
        .padding()
    }
}

struct GroupWidget: View {
    @ObservedObject var group: UserGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(GroupBackgroundColor.init(rawValue: group.backgroundColor)?.getColor())
                
                Text(group.emoji)
                    .font(.system(size: 25))
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 50, alignment: .leading)
            .padding([.horizontal, .top])
            
            Text(group.name)
                .font(.custom("Lexend-SemiBold", size: 20))
                .padding(.horizontal)
                .frame(height: 50)
                .lineLimit(2)
            
            HStack(alignment: .bottom, spacing: 0) {
                if group.activities.count == 1 {
                    TextHelper.text(key: "1 exercise", alignment: .leading, type: .challengeGroup)
                        .frame(width: 70)
                }
                else {
                    TextHelper.text(key: "\(group.activities.count) exercises", alignment: .leading, type: .challengeGroup)
                        .frame(width: 70)
                }
                
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
            .frame(height: 15)
            .padding([.horizontal, .bottom])
        }
        .background(Color("Panel"))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
