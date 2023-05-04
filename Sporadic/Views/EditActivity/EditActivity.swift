//
//  EditActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI


struct EditActivity: View {
    @Binding var activity: Activity
    @Environment(\.isPresented) var isPresented
    @State var currentMin = 0.0
    @State var currentMax = 0.0

    @StateObject var viewModel = AddActivityViewModel()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: GlobalSettings.shared.controlSpacing) {
                HStack {
                    Image(activity.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .center)
                        .padding()
                    
                    TextHelper.text(key: activity.name, alignment: .leading, type: .h3)
                    
                    Spacer()
                }
//                .background(
//                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
//                        .foregroundColor(activity.template?.color ?? Color("Panel"))
//                )
                
                TextHelper.text(key: "Edit exercise", alignment: .leading, type: .h1)
                    .padding(.top, 50)

                RangeSelection(minValue: $activity.minValue, maxValue: $activity.maxValue, unit: activity.unit, viewModel: viewModel)
                    .alert(isPresented: $viewModel.showError) {
                        Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
                    }

                DeleteButton(activity: $activity)
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(id: "BackButton", placement: .navigationBarLeading, showsByDefault: true) {
                BackButton()
            }
        }
        .onAppear {
            currentMin = activity.minValue
            currentMax = activity.maxValue
        }
        .onChange(of: isPresented) { newValue in
            if newValue == false {
                if currentMin != activity.minValue || currentMax != activity.maxValue {
                    activity.wasEdited = true
                }
            }
        }
    }
    
    struct DeleteButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @State var showDeleteConfirmation = false
        @Binding var activity: Activity
        
        var body: some View {
            HStack() {
                Button(action: {
                    showDeleteConfirmation = true
                }, label: {
                    Text("Remove")
                        .foregroundColor(.white)
                        .font(Font.custom("Lexend-SemiBold", size: 16, relativeTo: .title3))
                        .padding()
                        .background(Color("Failed"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        .padding(.bottom)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(title: Text("Remove \(activity.name)?"), message: Text("Add back an activity with the same name later to pick up where you left off."),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Remove")) {
                        activity.wasDeleted = true
                        
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                
                Spacer()
            }
        }
    }
}
