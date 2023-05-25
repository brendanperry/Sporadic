//
//  EditActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI


struct EditActivity: View {
    @Binding var activity: Activity
    @Binding var activities: [Activity]
    @Environment(\.isPresented) var isPresented
    @State var currentMin = 0.0
    @State var currentMax = 0.0
    @State var newMin: Double
    @State var newMax: Double

    @StateObject var viewModel = AddActivityViewModel()
    
    init(activity: Binding<Activity>, activities: Binding<[Activity]>) {
        self._activity = activity
        self._activities = activities
        
        self._currentMin = State(initialValue: activity.minValue.wrappedValue)
        self._currentMax = State(initialValue: activity.maxValue.wrappedValue)
        self._newMin = State(initialValue: activity.minValue.wrappedValue)
        self._newMax = State(initialValue: activity.maxValue.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: GlobalSettings.shared.controlSpacing) {
                BackButton()
                    .padding(.top)
                
                VStack {
                    if let template = activity.template {
                        ExerciseName(template: template)
                    }
                    
                    TextHelper.text(key: "Edit exercise", alignment: .leading, type: .h1)
                }

                RangeSelection(minValue: $newMin, maxValue: $newMax, unit: activity.unit, viewModel: viewModel)
                    .alert(isPresented: $viewModel.showError) {
                        Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
                    }

                DeleteButton(activity: $activity, activities: $activities)
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .navigationBarBackButtonHidden(true)
        .onChange(of: isPresented) { newValue in
            if newValue == false {
                if currentMin != newMin || currentMax != newMax {
                    activity.wasEdited = true
                    activity.minValue = newMin
                    activity.maxValue = newMax
                }
            }
        }
    }
    
    struct DeleteButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @State var showDeleteConfirmation = false
        @Binding var activity: Activity
        @Binding var activities: [Activity]
        
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
                        let deletedActivity = activities.first(where: { $0.record.recordID == activity.record.recordID })
                        
                        deletedActivity?.wasDeleted = true
                        
                        if let deletedActivity {
                            activities.removeAll(where: { $0.record.recordID == activity.record.recordID })
                            
                            if !deletedActivity.isNew {
                                activities.append(deletedActivity)
                            }
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                
                Spacer()
            }
        }
    }
}
