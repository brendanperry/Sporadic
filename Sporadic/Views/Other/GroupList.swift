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
    let updateNextChallengeText: () -> Void
    let hardRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TextHelper.text(key: "Groups", alignment: .leading, type: .h4)
                .padding(.horizontal)
                .padding(.bottom)

            LazyVGrid(columns: items, spacing: 17) {
                if isLoading && groups.isEmpty {
                    GroupLoadingWidget()
                }
                else {
                    ForEach($groups.filter({ !$0.wrappedValue.wasDeleted })) { group in
                        
                        if #available(iOS 17.0, *) {
                            NavigationLink(destination:
                                GroupOverview(group: group.wrappedValue, groups: $groups, updateNextChallengeText: updateNextChallengeText, hardRefresh: hardRefresh)
                                    .toolbarTitleDisplayMode(.inline)
                            ) {
                                GroupWidget(group: group.wrappedValue)
                            }
                            .buttonStyle(ButtonPressAnimationStyle())
                        } else {
                            NavigationLink(destination:
                                GroupOverview(group: group.wrappedValue, groups: $groups, updateNextChallengeText: updateNextChallengeText, hardRefresh: hardRefresh)
                            ) {
                                GroupWidget(group: group.wrappedValue)
                            }
                            .buttonStyle(ButtonPressAnimationStyle())
                        }
                    }

                    AddNewGroup(groups: $groups, updateNextChallengeText: updateNextChallengeText, groupCount: groups.count)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AddNewGroup: View {
    @Binding var groups: [UserGroup]
    let updateNextChallengeText: () -> Void
    let groupCount: Int
    
    var body: some View {
        NavigationLink(destination: CreateGroupView(groups: $groups, updateNextChallengeText: updateNextChallengeText, groupCount: groupCount)) {
            if groups.isEmpty {
                VStack(alignment: .leading) {
                    PlusButton(shape: Rectangle(), backgroundColor: .clear, lockLightMode: true, shadow: false)
                        .frame(width: 25, height: 25)
                        .padding(10)
                        .background(Circle().foregroundColor(Color("BrandPurple")))
                        .padding([.leading, .top])
                    
                    TextHelper.text(key: "Create a new group!", alignment: .leading, type: .h3)
                        .padding(.horizontal)
                        .frame(height: 50)
                        .lineLimit(2)
                        .padding(.bottom)
                }
                .background(Color("Panel"))
                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            }
            else {
                PlusButton(shape: Rectangle(), backgroundColor: Color("Panel"), lockLightMode: false, shadow: false)
                    .padding()
            }
        }
        .buttonStyle(ButtonPressAnimationStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
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
        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
    }
}

struct GroupWidget: View {
    @ObservedObject var group: UserGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GroupIcon(emoji: group.emoji, backgroundColor: group.backgroundColor)
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 50, alignment: .leading)
                .padding([.horizontal, .top])
            
            Text(group.name)
                .font(.custom("Lexend-SemiBold", size: 16))
                .foregroundColor(Color("Gray300"))
                .padding(.horizontal)
                .frame(height: 50)
                .lineLimit(2)
            
            HStack(alignment: .bottom) {
                if group.activities.count == 1 {
                    Text("1 exercise")
                        .font(Font.custom("Lexend-Regular", size: 12, relativeTo: .caption2))
                        .foregroundColor(Color("Gray200"))
                }
                else {
                    Text("\(group.activities.filter({ !$0.wasDeleted }).count) exercises")
                        .font(Font.custom("Lexend-Regular", size: 12, relativeTo: .caption2))
                        .foregroundColor(Color("Gray200"))
                }
                
                Image("View Group Carrot Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 5)
                        .offset(y: -3)
                
                Spacer()
            }
            .frame(height: 15)
            .padding([.horizontal, .bottom])
        }
        .background(Color("Panel"))
        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
    }
}
