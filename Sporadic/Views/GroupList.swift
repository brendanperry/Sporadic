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
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)
    @State var isActive = false
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Localize.getString("Groups"))
                    .font(.custom("Lexend-SemiBold", size: 14))
                    .foregroundColor(Color("Header"))
                    .frame(width: 50, alignment: .leading)
                
                if isLoading && !groups.isEmpty {
                    ProgressView()
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: items, spacing: 0) {
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
                    
                    AddNewGroup()
                }
            }
        }
    }
}

struct AddNewGroup: View {
    var body: some View {
        NavigationLink(destination: CreateGroupView()) {
            Image("Add Activity Icon Circle")
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
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
    let group: UserGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(GroupBackgroundColor.init(rawValue: group.backgroundColor)?.getColor())
                
                Text(group.emoji)
                    .font(.system(size: 25))
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 75, alignment: .leading)
            .padding([.horizontal, .top])
            
            TextHelper.text(key: "", alignment: .leading, type: .h3, prefix: group.name)
                .padding(.horizontal)
                .frame(height: 50)
                .lineLimit(2)
            
            HStack(alignment: .bottom, spacing: 0) {
                TextHelper.text(key: "EditGroup", alignment: .leading, type: .challengeGroup)
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
