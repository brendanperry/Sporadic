//
//  CreateGroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import SwiftUI
import UIKit
import Combine

struct CreateGroupView: View {
    @ObservedObject var viewModel = CreateGroupViewModel()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 20) {
                        TextHelper.text(key: "CreateGroup", alignment: .leading, type: .h1)
                        
                        GroupName(name: $viewModel.groupName)
                        
                        EmojiSelector(emoji: $viewModel.emoji)
                        
                        GroupColor(color: $viewModel.color)
                        
                        ActivitySelector(selectedActivities: $viewModel.activities, templates: viewModel.getTemplates(), group: viewModel.group)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                })
                .preferredColorScheme(ColorSchemeHelper().getColorSceme())
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Hi")
//        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(leading: BackButton())
        .onAppear {
            UINavigationBar.appearance().barTintColor = .red
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    struct GroupName: View {
        @Binding var name: String
        
        var body: some View {
            VStack {
                TextHelper.text(key: "GroupName", alignment: .leading, type: .h2)
                
                TextField("", text: $name)
                    .padding(10)
                    .background(Color("Panel"))
                    .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                    .cornerRadius(10)
            }
        }
    }
    
    struct EmojiSelector: View {
        @Binding var emoji: String

        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Emoji", alignment: .leading, type: .h2)
                
                EmojiTextField(text: $emoji)
                    .font(.system(size: 100))
                    .frame(width: 60, height: 60)
                    .background(Color("Panel"))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct GroupColor: View {
        @Binding var color: GroupBackgroundColor
        @State var selected = GroupBackgroundColor.one
        var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 4)
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Color", alignment: .leading, type: .h2)
                
                LazyVGrid(columns: items, spacing: 20) {
                    ForEach(GroupBackgroundColor.allCases, id: \.self) { color in
                        Circle()
                            .foregroundColor(color.getColor())
                            .frame(width: color == selected ? 40 : 50, height: color == selected ? 40 : 50, alignment: .center)
                            .animation(Animation.easeInOut, value: selected)
                            .onTapGesture {
                                withAnimation {
                                    selected = color
                                }
                            }
                    }
                }
                .padding()
                .background(Color("Panel"))
                .cornerRadius(16)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct CreateButton: View {
        let viewModel: CreateGroupViewModel
        
        var body: some View {
            Button(action: {
                Task {
                    viewModel.createGroup
                }
            }, label: {
                TextHelper.text(key: "CreateGroup", alignment: .center, type: .h2, color: .white)
                    .padding(10)
                    .background(Color("Purple"))
                    .cornerRadius(16)
            })
        }
    }
    
    struct ActivitySelector: View {
        @Binding var selectedActivities: [Activity]
        let templates: [ActivityTemplate]
        let group: UserGroup
        var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)

        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Choose activities", alignment: .leading, type: .h2)
                
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach(templates) { template in
                        ZStack {
//                            if selectedActivities.contains(where: { $0.id == template.id }) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .top, endPoint: .bottom))
//                            }
                            
                            VStack {
                                Image(template.name + " Circle")
                                    .resizable()
                                    .frame(width: 50, height: 50, alignment: .center)
                                
                                TextHelper.text(key: template.name, alignment: .center, type: .activityTitle, color: .white)
                                    .padding(5)
                                
                                TextHelper.text(key: "\(template.minValue) - \(template.maxValue) \(template.unit)", alignment: .center, type: .body, color: Color("EditProfile"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15).foregroundColor(Color("Activity"))
                            )
                            .padding(7)
                        }
                        .padding()
                    }
                    
                    NavigationLink(destination: AddPage(viewModel: AddActivityViewModel(group: group))) {
                        Image("Add Activity Full")
                            .resizable()
                            .frame(width: 75, height: 75, alignment: .center)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
